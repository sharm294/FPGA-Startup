#ifndef DEVICE_FILE_H_
#define DEVICE_FILE_H_
#include <linux/compiler.h> /* __must_check */

#include <linux/mutex.h>

__must_check int register_device(void); /* 0 if Ok*/

void unregister_device(void);
static DEFINE_MUTEX(pci_mutex); 

#endif //DEVICE_FILE_H_
