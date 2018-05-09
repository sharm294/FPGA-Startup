#include "device_file.h"
#include <linux/init.h> /* module_init, module_exit */
#include <linux/module.h> /* THIS_MODULE */

MODULE_LICENSE("Dual BSD/GPL");
MODULE_AUTHOR("Danil Ishkov (Apriorit), Varun Sharma (UofT)");
MODULE_DESCRIPTION("Triggers rescan of the PCI bus for an FPGA. Cat the device for help");
MODULE_VERSION("1.0");

/*===============================================================================================*/
static int rescan_init(void){
    int result = 0;

    result = register_device();

    mutex_init(&pci_mutex);

    return result;
}
/*-----------------------------------------------------------------------------------------------*/
static void rescan_exit(void){
    mutex_destroy(&pci_mutex);
    unregister_device();
}
/*===============================================================================================*/

module_init(rescan_init);
module_exit(rescan_exit);
