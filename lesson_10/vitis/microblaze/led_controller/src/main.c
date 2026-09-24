#include "xgpio.h"
#include "xparameters.h"
#include "xil_printf.h"
#include "xstatus.h"
#include "xil_types.h"
#include "xtmrctr.h"
#include "xintc.h"
#include "xil_exception.h"

#define GPIO_BASEADDR   XPAR_XGPIO_0_BASEADDR
#define TIMER_BASEADDR  XPAR_XTMRCTR_0_BASEADDR
#define INTC_BASEADDR   XPAR_XINTC_0_BASEADDR

#define GPIO_INTR_ID    XPAR_FABRIC_XGPIO_0_INTR     // GPIO -> INTC input 0
#define TIMER_INTR_ID   XPAR_FABRIC_XTMRCTR_0_INTR   // Timer -> INTC input 1

#define TIMER_NUMBER    0U  // Timer/Counter 0 inside AXI Timer IP

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

#define INITIAL_TIMER_TICKS  1000U  // 10 us @ 100 MHz
#define MIN_TIMER_TICKS       250U  // 2.5 us
#define MAX_TIMER_TICKS      4000U  // 40 us

#else

#define INITIAL_TIMER_TICKS   50000000U   // 500 ms @ 100 MHz
#define MIN_TIMER_TICKS       12500000U   // 125 ms
#define MAX_TIMER_TICKS      100000000U   // 1 s

#endif

static XGpio Gpio;
static XTmrCtr Timer;
static XIntc Intc;

static volatile u32 led_pattern = LED_FIRST;
static volatile int running = 1;
static volatile int direction = 0;  // 0: 0001 -> 1000, 1: 1000 -> 0001
static volatile u32 timer_ticks = INITIAL_TIMER_TICKS;

static u32 previous_buttons = 0U;


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

    XGpio_DiscreteWrite(&Gpio, LED_CHANNEL, led_pattern);
}


static void ApplyTimerPeriod(void)
{
    XTmrCtr_Stop(&Timer, TIMER_NUMBER);                   // Stop current timer period
    XTmrCtr_SetResetValue(&Timer, TIMER_NUMBER, timer_ticks);
    XTmrCtr_Start(&Timer, TIMER_NUMBER);                  // Reload and apply new period immediately
}


static void TimerHandler(void *CallBackRef, u8 TmrCtrNumber)
{
    (void)CallBackRef;
    (void)TmrCtrNumber;

    UpdateLedPattern();
}


static void ButtonHandler(void *CallBackRef)
{
    XGpio *GpioPtr = (XGpio *)CallBackRef;

    u32 buttons = XGpio_DiscreteRead(GpioPtr, BTN_CHANNEL);
    u32 pressed = buttons & ~previous_buttons;  // Detect only 0 -> 1 transitions

    previous_buttons = buttons;  // Save current state for the next interrupt

    XGpio_InterruptClear(
        GpioPtr,
        XGPIO_IR_CH2_MASK
    );  // Acknowledge GPIO interrupt

    if (pressed & BTN_START_STOP) {
        running = !running;  // Toggle running/stopped state
    }

    if (pressed & BTN_DIRECTION) {
        direction = !direction;  // Reverse running-light direction
    }

    if (pressed & BTN_FASTER) {
        if (timer_ticks > MIN_TIMER_TICKS) {
            timer_ticks >>= 1;  // Half period -> twice as fast

            if (timer_ticks < MIN_TIMER_TICKS) {
                timer_ticks = MIN_TIMER_TICKS;  // Clamp to maximum speed
            }

            ApplyTimerPeriod();  // Apply new period immediately
        }
    }

    if (pressed & BTN_SLOWER) {
        if (timer_ticks < MAX_TIMER_TICKS) {
            timer_ticks <<= 1;  // Double period -> twice as slow

            if (timer_ticks > MAX_TIMER_TICKS) {
                timer_ticks = MAX_TIMER_TICKS;  // Clamp to minimum speed
            }

            ApplyTimerPeriod();  // Apply new period immediately
        }
    }
}


int main(void)
{
    int status;

    status = XGpio_Initialize(&Gpio, GPIO_BASEADDR);
    if (status != XST_SUCCESS) {
        xil_printf("GPIO initialization failed\r\n");
        return XST_FAILURE;
    }

    XGpio_SetDataDirection(
        &Gpio,
        LED_CHANNEL,
        GPIO_LED_DIRECTION
    );  // All LED pins are outputs

    XGpio_SetDataDirection(
        &Gpio,
        BTN_CHANNEL,
        GPIO_BTN_DIRECTION
    );  // All button pins are inputs

    XGpio_DiscreteWrite(
        &Gpio,
        LED_CHANNEL,
        led_pattern
    );  // Start with LED0 active


    status = XTmrCtr_Initialize(&Timer, TIMER_BASEADDR);
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
        XTC_INT_MODE_OPTION |        // Interrupt on expiration
        XTC_AUTO_RELOAD_OPTION |     // Periodic operation
        XTC_DOWN_COUNT_OPTION        // Count down to zero
    );

    XTmrCtr_SetResetValue(
        &Timer,
        TIMER_NUMBER,
        timer_ticks
    );


    status = XIntc_Initialize(&Intc, INTC_BASEADDR);
    if (status != XST_SUCCESS) {
        xil_printf("INTC initialization failed\r\n");
        return XST_FAILURE;
    }

    status = XIntc_Connect(
        &Intc,
        TIMER_INTR_ID,
        (XInterruptHandler)XTmrCtr_InterruptHandler,  // Driver ISR for AXI Timer
        &Timer                                        // Passed to Timer driver ISR
    );

    if (status != XST_SUCCESS) {
        xil_printf("Timer interrupt connection failed\r\n");
        return XST_FAILURE;
    }

    status = XIntc_Connect(
        &Intc,
        GPIO_INTR_ID,
        (XInterruptHandler)ButtonHandler,  // Application ISR for GPIO
        &Gpio
    );

    if (status != XST_SUCCESS) {
        xil_printf("GPIO interrupt connection failed\r\n");
        return XST_FAILURE;
    }

    status = XIntc_Start(
        &Intc,
        XIN_REAL_MODE
    );  // Real peripheral IRQ path, also for RTL simulation

    if (status != XST_SUCCESS) {
        xil_printf("INTC start failed\r\n");
        return XST_FAILURE;
    }

    XIntc_Enable(&Intc, TIMER_INTR_ID);  // Unmask Timer IRQ in AXI INTC
    XIntc_Enable(&Intc, GPIO_INTR_ID);   // Unmask GPIO IRQ in AXI INTC

    XGpio_InterruptClear(
        &Gpio,
        XGPIO_IR_CH2_MASK
    );  // Remove possible stale GPIO IRQ

    XGpio_InterruptEnable(
        &Gpio,
        XGPIO_IR_CH2_MASK
    );  // Allow button channel to generate IRQ

    XGpio_InterruptGlobalEnable(
        &Gpio
    );  // Enable AXI GPIO interrupt output

    Xil_ExceptionInit();

    Xil_ExceptionRegisterHandler(
        XIL_EXCEPTION_ID_INT,
        (Xil_ExceptionHandler)XIntc_InterruptHandler,  // Top-level AXI INTC ISR
        &Intc
    );

    Xil_ExceptionEnable();  // Allow MicroBlaze to accept interrupts

    XTmrCtr_Start(
        &Timer,
        TIMER_NUMBER
    );  // Start Timer only after the complete IRQ path is ready

#ifdef SIMULATION
    xil_printf("LED controller initialized [SIMULATION]\r\n");
#else
    xil_printf("LED controller initialized [HARDWARE]\r\n");
#endif

    while (1) {
        // Interrupt-driven application: all work happens in ISRs
    }

    return 0;
}