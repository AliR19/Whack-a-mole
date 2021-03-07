# Whack-a-mole
Whack-a-mole game programmed on the VLdiscovery board using Cortex m3 assembly language via Keil uVision

# What the game is?
This Whack-a-mole game consist of 4 LEDs with 4 pushbuttons. 
   The user has to hit any of the push buttons in response to the
   linked LED that is ON. Once the game starts, random LEDs will
   start blinking in random fashion and the player has to respond
   before that LED turns off by pressing that pushbutton.LEDs
   represents the mole and the pushbutton represents the hammer hitting the mole.
   The faster the player hits the pushbutton, the harder the difficulty
   level gets by providing lesser react time. The player gets certain
   number of chances and if he/she fails to hit the button in time 
   or hits the incorrect button, the player wll fail and the game will
   be ended. So to win the game, th player has to continuously hit all the 
   pushbuttons correctly in the react time.
 # How to play the game?
 To play the game, there are certain steps to be followed:
   a) At first the LED pattern is in a continuous cycling pattern with a
      frequency of 1 Hz. This shows that it is waiting for the player to start
      the game.
   b) When player presses any of the buttons, the LEDs all turn off and 
      waits for a certain PrelimWait time to elapse before starting the
      game.
   c) The game will start and a certain random LED will turn on and off
      with a "ON" time of few milliseconds.The player is expected to hit
      the pushbutton within this time frame to mark a score.
   d) If the user fails to do so, a fail pattern is displayed using the
      combination of 4 LEDs for a certain time period.Then the score of
      the user is flashed accross the 4 LEDs by converting to binary.
      Post this, the game again goes back into the wait mode by waiting 
      for next game to start.
   e) If the player hits correctly, then his score counter is incremented
      and he is given another attempt to hit, failing which the game ends.
   f) After all the trials are completed, the winning pattern is generated
      using some specific LED pattern and the profeciency level(final 
      winning score of 15) is displayed using all LEDs turned on and remaining
      in this state for next 1 minute
   g) Post this, new game starts
   # Possible future expansion?
   In the near future, code can be added to
   take care of displaying the final score when the number of trials/attempts
   is more than 15. So it would need to re-use the 4 LED two times to
   represent an 8 bit number between 16 and 255.
   # How the user can adjust the game parameters?
   To adjust the game paramters:
   a) PrelimWait: The current PrelimWait is set to 3000000 and can be
      changed by configuring "PRELIMTIME" defined.
   b) ReactTime: The curent ReactTime is 2100000. To adjust this, the 
      player has to change the parameter "REACTTIME". Current reacttime 
      keeps decrementing for every cycle with a decrement value present
      in TIMEDIFF which is set to 120000.
   c) NumCycles: The current NumCycles is set to 15 through the parameter
      "NUMCYCLES" since the maximum number displayed using 4 LEDS is 15. If
      the user wnats to give a higher number, he/she has to change this
      parameter.
   d) Value of WinningSignalTime comes out to be approximately 20 seconds.
      It is product of two paramters WINNINGSIGNALTIME and WINDELAYTIME
      wih their values being 100 and 200000 respectively.
      Value of LosingSignalTime comes out to be approximately 26 seconds.
      It is product of two parameters LOSINGSIGNALTIME and 4*(DELAYTIME)
      with their values being 5 and 4*120000.
