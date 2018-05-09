#include "device_file.h"
#include <linux/fs.h> /* file stuff */
#include <linux/kernel.h> /* printk() */
#include <linux/errno.h> /* error codes */
#include <linux/module.h> /* THIS_MODULE */
#include <linux/cdev.h> /* char device stuff */
#include <asm/uaccess.h> /* copy_to_user() */
#include <linux/kmod.h> /* call_usermodehelper() */
#include <linux/slab.h> /* kmalloc */
#include <linux/mutex.h>

static const char    g_s_read_string[] = "usage: echo PASSWORD > /dev/rescan-fpga\n\0";
static const ssize_t g_s_read_size = sizeof(g_s_read_string);

static const char string_bin[] = "/bin/bash";
static const ssize_t bin_size = sizeof(string_bin);

//PATH_SUBSTITUTION: note this comment must remain as-is
static const char string_path[] = "/home/savi/"
static const ssize_t path_size = sizeof(string_path);

static const ssize_t null_size = sizeof(NULL);

/*===============================================================================================*/
static int device_open(
    struct inode *inodep,
    struct file *filep
){
    if(!mutex_trylock(&pci_mutex)){
        printk(KERN_ALERT "rescan-fpga is in use by another process");
        return -EBUSY;
    }
    return 0;
}

/*===============================================================================================*/
static int device_release(
    struct inode *inodep,
    struct file *filep
){
    mutex_unlock(&pci_mutex);
    return 0;
}

/*===============================================================================================*/
static ssize_t device_file_read(
    struct file *file_ptr,
    char __user *user_buffer,
    size_t count,
    loff_t *possition
){

    if( *possition >= g_s_read_size )
        return 0;

    if( *possition + count > g_s_read_size )
        count = g_s_read_size - *possition;

    if( copy_to_user(user_buffer, g_s_read_string + *possition, count) != 0 )
        return -EFAULT;

    *possition += count;
    return count;
}

/*===============================================================================================*/
static ssize_t device_file_write(
    struct file *file_ptr,
    const char *buffer,
    size_t len,
    loff_t *offset
){

    char * envp[] = { "HOME=/", NULL };
    char * argv[4];

    argv[0] = kmalloc(sizeof(char)*bin_size, GFP_KERNEL);
    memcpy(argv[0], string_bin, bin_size);

    argv[1] = kmalloc(sizeof(char)*path_size, GFP_KERNEL);
    memcpy(argv[1], string_path, path_size);

    argv[2] = kmalloc(sizeof(char)*(len+1), GFP_KERNEL);
    if( copy_from_user(argv[2], buffer, len) != 0){
        kfree(argv[0]);
        kfree(argv[1]);
        kfree(argv[2]);
        return -EFAULT;
    }
    argv[2][len] = '\0';

    argv[3] = NULL;

    int retVal = call_usermodehelper(argv[0], argv, envp, UMH_WAIT_EXEC);
    if(retVal == -100){
        printk(KERN_ERR "Error: Double-check password or contact admin\n");
        kfree(argv[0]);
        kfree(argv[1]);
        kfree(argv[2]);
        return -1;
    }

    kfree(argv[0]);
    kfree(argv[1]);
    kfree(argv[2]);
    
    if(retVal != 0)
        return -EFAULT;
    else
        return len;

}

/*===============================================================================================*/
static struct file_operations rescan_fpga_fops = {
    .owner   = THIS_MODULE,
    .read    = device_file_read,
    .write   = device_file_write,
    .open    = device_open,
    .release = device_release,
};

static int device_file_major_number = 0;

static const char device_name[] = "rescan-fpga";

/*===============================================================================================*/
int register_device(void){
      int result = 0;

      result = register_chrdev( 0, device_name, &rescan_fpga_fops );
      if( result < 0 ){
         printk( KERN_WARNING "rescan-fpga:  can\'t register character device with errorcode = %i", result );
         return result;
      }

      device_file_major_number = result;

      return 0;
}
/*-----------------------------------------------------------------------------------------------*/
void unregister_device(void){
   if(device_file_major_number != 0){
      unregister_chrdev(device_file_major_number, device_name);
   }
}
