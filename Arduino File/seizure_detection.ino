#include <LiquidCrystal.h>

LiquidCrystal lcd(8, 9, 4, 5, 6, 7);    // select pins used on the LCD panel

int incomingByte = 0;   // for incoming serial data
int cancel = 0;   // cancel detection
int value;

// define some values used by the panel and buttons
int lcd_key     = 0;
int adc_key_in  = 0;
#define btnRIGHT  0
#define btnUP     1
#define btnDOWN   2
#define btnLEFT   3
#define btnSELECT 4
#define btnNONE   5
 
// read the buttons
int read_LCD_buttons()
{
 adc_key_in = analogRead(0);      // read the value from the sensor 
 if (adc_key_in > 1500) return btnNONE; // We make this the 1st option for speed reasons since it will be the most likely result
 if (adc_key_in < 50)   return btnRIGHT;  
 if (adc_key_in < 195)  return btnUP; 
 if (adc_key_in < 380)  return btnDOWN; 
 if (adc_key_in < 500)  return btnLEFT; 
 if (adc_key_in < 700)  return btnSELECT;   
 return btnNONE;  // when all others fail, return this...
}


void setup() {
  lcd.begin(16,2);   // start the library
  Serial.begin(9600);   // opens serial port, sets data rate to 9600 bps
  pinMode(10,OUTPUT);
  digitalWrite(10,LOW);
}

void loop() {
  lcd.setCursor(0,0);   // set the LCD cursor position

  lcd_key = read_LCD_buttons();
  if (lcd_key == 1){
    value = 0;
    cancel = 1;
    Serial.println("cancel");
  }
  
  if (Serial.available() > 0 || cancel == 1){

    Serial.println(value);
    incomingByte = Serial.read();
    value = incomingByte-48;
    Serial.println(value);
    
    if (value == 1){
      lcd.print("SEIZURE DETECTED");
      lcd.setCursor(0,1);
      lcd.print("If OK press UP");
      digitalWrite(10,HIGH);
    }

    if (value == 0 || value == -49){
      digitalWrite(13,LOW);
      lcd.clear();
      digitalWrite(10,LOW);
      cancel = 0;
    }
  }
    
}
  
