import RPi.GPIO as GPIO
import time
from time import sleep

# Set up the GPIO board
GPIO.setmode(GPIO.BOARD)
GPIO.setup(11, GPIO.OUT)

# Set up PWM on pin 11 with a frequency of 100Hz
my_pwm = GPIO.PWM(11, 50)
my_pwm.start(1)  # Start PWM with a 1% duty cycle

GPIO.setmode(GPIO.BCM)

TRIG_PIN = 23
ECHO_PIN = 24

GPIO.setup(TRIG_PIN, GPIO.OUT)
GPIO.setup(ECHO_PIN, GPIO.IN)

try:
    while True:
        GPIO.output(TRIG_PIN, GPIO.LOW)
        time.sleep(2)

        GPIO.output(TRIG_PIN, GPIO.HIGH)
        time.sleep(0.00001)
        GPIO.output(TRIG_PIN, GPIO.LOW)

        while GPIO.input(ECHO_PIN) == 0:
            pulse_send = time.time()

        while GPIO.input(ECHO_PIN) == 1:
            pulse_received = time.time()

        pulse_duration = pulse_received - pulse_send
        distance = (pulse_duration * 34300) / 2
        distance = round(distance, 2)
        
        while distance <= 10 :
            if (dutycycle < 12)
                dutycycle = dutycycle+1
                
            my_pwm.ChangeDutyCycle(dutycycle)  
            
        while distance >= 10 :
            if (dutycycle > 1)
                dutycycle = dutycycle-1
                
            my_pwm.ChangeDutyCycle(dutycycle)

        print(f"Distance: {distance} cm")

        time.sleep(0.1)  # Add a delay between measurements

except KeyboardInterrupt:
    GPIO.cleanup()

