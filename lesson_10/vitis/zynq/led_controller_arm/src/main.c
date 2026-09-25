#include "xgpio.h"
#include "xparameters.h"
#include "xil_printf.h"
#include "xstatus.h"
#include "xil_types.h"
#include "xtmrctr.h"
#include "xscugic.h"
#include "xil_exception.h"


#define GPIO_BASEADDR   XPAR_XGPIO_0_BASEADDR
#define TIMER_BASEADDR  XPAR_XTMRCTR_0_BASEADDR
#define INTC_BASEADDR   XPAR_XSCUGIC_0_BASEADDR

#define GPIO_INTR_ID    XPAR_FABRIC_XGPIO_0_INTR
#define TIMER_INTR_ID   XPAR_FABRIC_XTMRCTR_0_INTR

#define TIMER_NUMBER    0U

#define LED_CHANNEL     1U
#define BTN_CHANNEL     2U

#define BTN_START_STOP  0x01U  // 0001
#define BTN_DIRECTION   0x02U  // 0010
#define BTN_FASTER      0x04U  // 0100
#define BTN_SLOWER      0x08U  // 1000

#define LED_FIRST       0x01U  // 0001
#define LED_LAST        0x08U  // 1000

#define GPIO_LED_DIRECTION  0x0U  // Output
#define GPIO_BTN_DIRECTION  0xFU  // Input


#ifdef SIMULATION

#define INITIAL_TIMER_TICKS  1000U   // 10 us @ 100 MHz
#define MIN_TIMER_TICKS       250U   // 2.5 us
#define MAX_TIMER_TICKS      4000U   // 40 us

#else

#define INITIAL_TIMER_TICKS   50000000U   // 500 ms
#define MIN_TIMER_TICKS       12500000U   // 125 ms
#define MAX_TIMER_TICKS      100000000U   // 1 s

#endif


static XGpio Gpio;
static XTmrCtr Timer;
static XScuGic Intc;

static volatile u32 led_pattern = LED_FIRST;
static volatile int running = 1;
static volatile int direction = 0;  // 0: 0001 -> 1000, 1: reverse
static volatile u32 timer_ticks = INITIAL_TIMER_TICKS;

static u32 previous_buttons = 0U;


/*
 * Move running light by one position.
 */
static void UpdateLedPattern(void)
{
    if (!running) {
        return;  // Keep current LED active while stopped
    }

    if (direction == 0) {
        led_pattern = (led_pattern == LED_LAST)
                    ? LED_FIRST
                    : (led_pattern << 1);
    } else {
        led_pattern = (led_pattern == LED_FIRST)
                    ? LED_LAST
                    : (led_pattern >> 1);
    }

    XGpio_DiscreteWrite(
        &Gpio,
        LED_CHANNEL,
        led_pattern
    );
}


/*
 * Apply a new timer period immediately.
 */
static void ApplyTimerPeriod(void)
{
    XTmrCtr_Stop(
        &Timer,
        TIMER_NUMBER
    );

    XTmrCtr_SetResetValue(
        &Timer,
        TIMER_NUMBER,
        timer_ticks
    );

    XTmrCtr_Start(
        &Timer,
        TIMER_NUMBER
    );
}


/*
 * Our callback called by the AXI Timer driver ISR.
 */
static void TimerHandler(void *CallBackRef, u8 TmrCtrNumber)
{
    (void)CallBackRef;
    (void)TmrCtrNumber;

    UpdateLedPattern();
}


/*
 * GPIO interrupt handler.
 */
static void ButtonHandler(void *CallBackRef)
{
    XGpio *GpioPtr = (XGpio *)CallBackRef;

    u32 buttons = XGpio_DiscreteRead(
        GpioPtr,
        BTN_CHANNEL
    );

    // React only to 0 -> 1 transitions
    u32 pressed = buttons & ~previous_buttons;

    previous_buttons = buttons;

    // GPIO interrupt must be acknowledged manually
    XGpio_InterruptClear(
        GpioPtr,
        XGPIO_IR_CH2_MASK
    );


    if (pressed & BTN_START_STOP) {
        running = !running;
    }


    if (pressed & BTN_DIRECTION) {
        direction = !direction;
    }


    if (pressed & BTN_FASTER) {
        if (timer_ticks > MIN_TIMER_TICKS) {

            timer_ticks >>= 1;  // Half period -> twice as fast

            if (timer_ticks < MIN_TIMER_TICKS) {
                timer_ticks = MIN_TIMER_TICKS;
            }

            ApplyTimerPeriod();
        }
    }


    if (pressed & BTN_SLOWER) {
        if (timer_ticks < MAX_TIMER_TICKS) {

            timer_ticks <<= 1;  // Double period -> twice as slow

            if (timer_ticks > MAX_TIMER_TICKS) {
                timer_ticks = MAX_TIMER_TICKS;
            }

            ApplyTimerPeriod();
        }
    }
}


/*
 * Configure ARM Cortex-A9 GIC.
 */
static int SetupInterruptSystem(void)
{
    int status;

    XScuGic_Config *IntcConfig;


    /*
     * In the current SDT flow we identify GIC by base address.
     */
    IntcConfig = XScuGic_LookupConfig(INTC_BASEADDR);

    if (IntcConfig == NULL) {
        xil_printf("GIC configuration lookup failed\r\n");
        return XST_FAILURE;
    }


    status = XScuGic_CfgInitialize(
        &Intc,
        IntcConfig,
        IntcConfig->CpuBaseAddress
    );

    if (status != XST_SUCCESS) {
        xil_printf("GIC initialization failed\r\n");
        return XST_FAILURE;
    }


    /*
     * Connect AXI Timer interrupt.
     *
     * Hardware path:
     *
     * AXI Timer
     *    -> IRQ_F2P
     *    -> ARM GIC
     *    -> XTmrCtr_InterruptHandler()
     *    -> TimerHandler()
     */
    status = XScuGic_Connect(
        &Intc,
        TIMER_INTR_ID,
        (Xil_ExceptionHandler)XTmrCtr_InterruptHandler,
        &Timer
    );

    if (status != XST_SUCCESS) {
        xil_printf("Timer interrupt connection failed\r\n");
        return XST_FAILURE;
    }


    /*
     * Connect AXI GPIO interrupt directly to our handler.
     */
    status = XScuGic_Connect(
        &Intc,
        GPIO_INTR_ID,
        (Xil_ExceptionHandler)ButtonHandler,
        &Gpio
    );

    if (status != XST_SUCCESS) {
        xil_printf("GPIO interrupt connection failed\r\n");
        return XST_FAILURE;
    }


    /*
     * PL -> PS interrupts are active-high, level-sensitive.
     *
     * Priority 0xA0 is sufficient for this application.
     */
    XScuGic_SetPriorityTriggerType(
        &Intc,
        GPIO_INTR_ID,
        0xA0,
        0x01
    );

    XScuGic_SetPriorityTriggerType(
        &Intc,
        TIMER_INTR_ID,
        0xA0,
        0x01
    );


    XScuGic_Enable(
        &Intc,
        GPIO_INTR_ID
    );

    XScuGic_Enable(
        &Intc,
        TIMER_INTR_ID
    );


    /*
     * Connect ARM exception mechanism to GIC.
     */
    Xil_ExceptionInit();

    Xil_ExceptionRegisterHandler(
        XIL_EXCEPTION_ID_INT,
        (Xil_ExceptionHandler)XScuGic_InterruptHandler,
        &Intc
    );

    Xil_ExceptionEnable();


    return XST_SUCCESS;
}


int main(void)
{
    int status;


    xil_printf("\r\n");
    xil_printf("====================================\r\n");
    xil_printf(" PYNQ-Z2 ARM LED controller\r\n");
    xil_printf("====================================\r\n");


    /*
     * ---------------------------------------------------------
     * GPIO
     * ---------------------------------------------------------
     */

    status = XGpio_Initialize(
        &Gpio,
        GPIO_BASEADDR
    );

    if (status != XST_SUCCESS) {
        xil_printf("GPIO initialization failed\r\n");
        return XST_FAILURE;
    }


    XGpio_SetDataDirection(
        &Gpio,
        LED_CHANNEL,
        GPIO_LED_DIRECTION
    );

    XGpio_SetDataDirection(
        &Gpio,
        BTN_CHANNEL,
        GPIO_BTN_DIRECTION
    );


    // Start with LED0 active
    XGpio_DiscreteWrite(
        &Gpio,
        LED_CHANNEL,
        led_pattern
    );


    /*
     * ---------------------------------------------------------
     * AXI Timer
     * ---------------------------------------------------------
     */

    status = XTmrCtr_Initialize(
        &Timer,
        TIMER_BASEADDR
    );

    if (status != XST_SUCCESS) {
        xil_printf("Timer initialization failed\r\n");
        return XST_FAILURE;
    }


    XTmrCtr_SetHandler(
        &Timer,
        TimerHandler,
        &Timer
    );


    XTmrCtr_SetOptions(
        &Timer,
        TIMER_NUMBER,
        XTC_INT_MODE_OPTION |
        XTC_AUTO_RELOAD_OPTION |
        XTC_DOWN_COUNT_OPTION
    );


    XTmrCtr_SetResetValue(
        &Timer,
        TIMER_NUMBER,
        timer_ticks
    );


    /*
     * ---------------------------------------------------------
     * ARM GIC
     * ---------------------------------------------------------
     */

    status = SetupInterruptSystem();

    if (status != XST_SUCCESS) {
        return XST_FAILURE;
    }


    /*
     * ---------------------------------------------------------
     * GPIO interrupt
     * ---------------------------------------------------------
     */

    XGpio_InterruptClear(
        &Gpio,
        XGPIO_IR_CH2_MASK
    );

    XGpio_InterruptEnable(
        &Gpio,
        XGPIO_IR_CH2_MASK
    );

    XGpio_InterruptGlobalEnable(
        &Gpio
    );


    /*
     * Start Timer only after the complete interrupt path
     * has been configured.
     */
    XTmrCtr_Start(
        &Timer,
        TIMER_NUMBER
    );


#ifdef SIMULATION
    xil_printf("LED controller initialized [SIMULATION]\r\n");
#else
    xil_printf("LED controller initialized [HARDWARE]\r\n");
#endif

    xil_printf("GPIO base  : 0x%08lx\r\n", (unsigned long)GPIO_BASEADDR);
    xil_printf("Timer base : 0x%08lx\r\n", (unsigned long)TIMER_BASEADDR);
    xil_printf("GPIO IRQ   : %lu\r\n", (unsigned long)GPIO_INTR_ID);
    xil_printf("Timer IRQ  : %lu\r\n", (unsigned long)TIMER_INTR_ID);


    while (1) {
        // Interrupt-driven application
    }


    return 0;
}