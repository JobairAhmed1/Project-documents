import RPi.GPIO as GPIO

# Set up the GPIO board
GPIO.setmode(GPIO.BOARD)
GPIO.setup(11, GPIO.OUT)

# Set up PWM on pin 11 with a frequency of 100Hz
my_pwm = GPIO.PWM(11, 100)
my_pwm.start(50)  # Start PWM with a 50% duty cycle

stopit = False

# Main loop
while not stopit:
    dutycycle = input("Enter % Duty Cycle (or 1 to stop): ")
    if dutycycle == '1':
        stopit = True
    else:
        my_pwm.ChangeDutyCycle(int(dutycycle))

# Clean up GPIO
my_pwm.stop()
GPIO.cleanup()

print("Okay, bye-bye...")
