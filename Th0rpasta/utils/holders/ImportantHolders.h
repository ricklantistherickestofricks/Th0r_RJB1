//
//  ImportantHolders.h


#ifndef ImportantHolders_h
#define ImportantHolders_h

#include <stdio.h>

extern uint A12;
extern mach_port_t tfp0;
extern uint64_t kbase;
extern uint isA12;
extern uint64_t ktask;
extern uint64_t task_self_addr_cache;
extern uint64_t selfproc_ffs;
void setA12(uint a12);

void set_tfp0(mach_port_t tfp0wo);

void set_task_self_addr(uint64_t tsa);

void set_selfproc(uint64_t proc);
uint64_t get_selfproc(void);
#endif /* ImportantHolders_h */
