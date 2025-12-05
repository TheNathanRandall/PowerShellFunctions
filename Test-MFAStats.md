# Testing MFA Statistics

## About

I got curious about how random the random two-digit MFA prompt from Microsoft really was. So I started recording all of the ones I had to enter (varying from five to ten times a day) to run statsitics on them.

But it wasn't _just_ randomness I was curious about, but rather the distribution of how __difficult__ it is to enter specific numbers, based on the patterns involved. 

## Background

Difficulty is a measure of how complicated it is to enter the two digits sequentially, but this is, at best, complicated to determine, for difficulty is both a physical and psychological phenomenon, and both phenomenon vary by individual. Individual difficulty varies; I personally find it easier to move from top to bottom and left to right.

But for simplicity, I reduced this to Manhattan Distance, aks L1 or taxicab distance, which simply measures distance moved on X and Y axes. Every step up or down the rows, or left and right across rows, counts for one. So, looking at the keypad below:

* 11 would be zero steps
* 12 and 14 would be one step
* 15 and 13 would be two steps
* 19 and 10 would be four steps

| | | |
|-|-|-|
|1|2|3|
|4|5|6|
|7|8|9|
|*|0|#|

## Processing

I collected 300+ codes, which are included in the script.

I built an array of digits with their X/Y coordinates, then created an array of all numbers from 0 (aka 00) to 99 with the number, its two-digit string representation, and the calculated number of steps between the digits (Manhattan distance). I then grouped them by the number of steps, and created a variable __M*n*__ for each step set.

From there, I grouped the codes by number of steps each employed, and for each group figured out the percentage of codes employed that number of steps, and how that varied from the percentage of _possible_ codes for that number of steps. And of course, prettied up the output.

<img width="243" height="122" alt="Stats all nums" src="https://github.com/user-attachments/assets/2c820d95-c1b8-4895-ac59-ccde5cd64574" />

## Validating

At first glance that looks like it leans towards easier codes, heavily into same digit/zero step codes and away from the furthest possible four step codes. But what numbers were __not__ represented?

```powershell
$IndividualUse.Where({-not $PSItem.TimesUsed}).Num -join ', '
00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 12, 21, 39, 76
```

Wait a minute, __no__ codes started with a zero? How had I not noticed that before? And yet there it was. Which of course, meant I needed to change the statistics I was using from a set of 100 codes (00 to 99) to a set of 90. Once I ran that:

<img width="241" height="120" alt="Stats two digits" src="https://github.com/user-attachments/assets/c5b3e1dc-16ec-4487-92b7-b7aabb5123e9" />

Closer to an even distribution, but still weighted towards the easiest and away from the hardest codes to enter.

