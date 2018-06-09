TITLE Program 4     (Program_4.asm)

; Author: Anne Harris	annekharris@gmail.com
; Course / Project ID: CS271-400 / Program 4                Date: 2/18/2018
; Description: This program takes a user entered number between 1 and 400, validates
;	that number is in range, then displays that number of composite numbers on
;	the screen

INCLUDE Irvine32.inc

;Constants
UPPER_LIM = 400
LOWER_LIM = 1

.data

;string variables
prgmTitle	BYTE	"Composite Numbers		by Anne Harris",0
instruction	BYTE	"Enter the number of composite numbers you would like to see.",0dh, 0ah
			BYTE	"The max number you can enter is 400.",0
prompt		BYTE	"Enter the number of composites to display [1..400]: ",0
error		BYTE	"That number is out of range, try again please.",0
goodbye		BYTE	"Results certified by Anne Harris, goodbye!",0
space		BYTE	"   ",0

;data variables
userNum		DWORD	?		;user entered number for number of composites to display
isValid		DWORD	0		;check if number is valid (1 is true, 0 is false)
checkNum	DWORD	?		;divisor, gets set & incremented in isComposite proc
isPrime		DWORD	0		;check if number is prime (1 is true, 0 is false)
nextNum		DWORD	3		;the number being tested to see if prime or composite
							;will start at 3 beacuse 1,2 and 3 are prime numbers. This
							;variable will immediatly get incremented to 4
lineCount	DWORD	0		;number of values printed

.code
main PROC
	;introduce the program
	call	introduction
	;get the user input for number of composites to display
	call	getUserData
	;calculate composites and print the appropriate values
	call	showComposites
	;display goodby message
	call	farewell

	exit	; exit to operating system
main ENDP

;-------------------------------------------------
;introduction
;
;Displays the program title and instructions
;Receives: global string variables prgmTitle, instrcution
;Returns: n/a
;Preconditions: n/a
;Registers Changed: edx
;-------------------------------------------------
introduction PROC
	;display program title
	mov		edx, OFFSET prgmTitle
	call	WriteString
	call	Crlf
	call	Crlf

	;display instructions
	mov		edx, OFFSET instruction
	call	WriteString
	call	Crlf
	call	Crlf
	
	;return to main procedure
	ret
introduction ENDP

;-------------------------------------------------
;getUserData
;
;Reads the user integer input and calls the 
;	validate procedure
;Receives: global variables prompt, isValid, error
;Returns: valid number in userNum
;Preconditions: 0 < userNum < 401
;Registers Changed: edx, eax, ebx
;-------------------------------------------------
getUserData PROC
start:
	mov		edx, OFFSET prompt
	call	WriteString
	call	ReadInt
	mov		userNum, eax

	;call validate procedure
	call	validate

	;assess results of validation procedure
	mov		ebx, isValid
	cmp		ebx, 1
	je		prcFin

errorMsg:
	mov		edx, OFFSET error
	call	WriteString
	call	Crlf
	jmp		start
	
prcFin:					;procedure finished, ready to return
	ret
getUserData ENDP

;-------------------------------------------------
;validate
;
;Verifies that the user entered number is between
;	1 and 400
;Receives: global variables, UPPER_LIM, LOWER_LIM, 
;	isValid
;Returns: a 0 or 1 in isValid variable
;Preconditions: userNum is in eax
;Registers Changed: eax, ebx
;-------------------------------------------------
validate PROC
	;compare userNum in eax to upper limit (400)
	cmp		eax, UPPER_LIM
	jg		isFalse			;set isValid to false
	;compare userNum in eax to lower limit (1)
	cmp		eax, LOWER_LIM	
	jl		isFalse			;set isValid to false

isTrue:						;data is valid
	mov		ebx, 1			;set variable to true
	mov		isValid, ebx
	jmp		prcDone			;exit procedure

isFalse:					;data is not valid
	mov		ebx, 0			;set variable to false
	mov		isValid, ebx

prcDone:					;procedure done, ready to return
	ret
validate ENDP

;-------------------------------------------------
;showComposites
;
;Takes the user entered number and calls isComposite
;procedure, prints if isComposite procedure sets isPrime
;variable to false
;Receives: global variables userNum, nextNum, isPrime,
;	lineCount, space
;Returns: n/a, numbers will be printed
;Preconditions: 0 < userNum < 401
;Registers Changed: ecx, eax, edx
;-------------------------------------------------
showComposites PROC
	call	Crlf
;move number to be printed into the counter
	mov		ecx, userNum
checkLoop:
	inc		nextNum				;advance next number
	call	isComposite			;call isComposite procedure
	cmp		isPrime, 1			;if is prime is set to 1, number shouldn't be printed
	je		advance

printNum:
	mov		eax, nextNum
	call	WriteDec
	inc		lineCount
	cmp		lineCount,10		;check to see if line printed has 10 nums already
	je		lineEnter			
lineSpace:
	mov		edx, OFFSET space
	call	WriteString
	jmp		advance2
lineEnter:
	mov		lineCount, 0
	call	Crlf
	jmp		advance2

advance:
	inc		ecx					;if number was not printed, increase counter
	loop	checkLoop
advance2:
	loop	checkLoop			;number was printed, ready to loop

	ret
showComposites ENDP

;-------------------------------------------------
;isComposite
;
;Tests if the number is prime by dividing by 8 differnt
;	numbers between 2 and 19. Sets isPrime variable
;	accordingly
;Receives: global variables checkNum, nextNum, isPrime
;Returns: 0 or 1 in isPrime
;Preconditions: 0 < nextNum < 401
;Registers Changed: eax, ebx, edx
;-------------------------------------------------
isComposite PROC
	;test is number is divisible by 2,3,5,7,11,13,17,19
	;checking for those numbers because the square root of 400 
	;is 20, thus check odd numbers less than 20 

	;start check num at 3
	mov		checkNum,3

	;test the nubmer that is nextNum
	;test for divisibility by 2
	mov		eax, nextNum
	cdq
	mov		ebx, 2
	div		ebx
	;compare remainder to 0
	cmp		edx, 0
	je		noPrime		;is a composite number

primeLoop:
	;test the nubmer that is nextNum
	mov		eax, nextNum	
	cdq
	mov		ebx, checkNum	;divisor
	div		ebx
	;increase check number by 2 to go to next odd number
	add		ebx, 2
	mov		checkNum, ebx
	;compare 1 to quotient to make sure it didn't divide by itself
	cmp		eax, 1
	je		less19		;quotent is 1 it's prime, move to next step
	cmp		edx, 0
	je		noPrime		;is a composite number
	jmp		less19

less19:					;checks to see if divisor is greater than 19
	cmp		checkNum,19
	jg		yesPrime	;if greater, it's a prime number no need to check
	jle		primeLoop	;if less or equal, check against the new increased num

yesPrime:				;is not composite
	mov		ebx, 1
	mov		isPrime, ebx
	jmp		doneCheck

noPrime:				;is composite
	mov		ebx, 0
	mov		isPrime, ebx

doneCheck:				;ready to return
	ret
isComposite ENDP

;-------------------------------------------------
;farewell
;
;Displays goodbye message to user
;Receives: global variable goodbye
;Returns: n/a
;Preconditions: none
;Registers Changed: edx
;-------------------------------------------------
farewell PROC
	call	Crlf
	mov		edx, OFFSET goodbye
	call	WriteString
	call	Crlf

	ret
farewell ENDP

END main
