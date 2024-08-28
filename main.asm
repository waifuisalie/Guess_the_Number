	jmp		inicio
.include "my_tx_rx.inc"
 
inicio:
	call config_serial
	nop
	nop

sorteio_init:
	txs		string_greetings_game
	push	R16		
sorteio_reset:
	ldi		R18, 0
sorteio_loop:
	cpi		R18, 10
	breq	sorteio_reset

	// if flag receive complete is clear, keep picking new number.   no new data = 0x22
	// if flag receive complete is set, stop and check if its '+'   new data = 0xA2

	lds		R16, UCSR0A			// loading mr buffer
	sbrs	R16, 7				// if this is set, there is new data, which means we gotta go see what it is
	rjmp	inc_R18_to_loop		// will be skipped if new data, if not will keep picking new number

	lds		R17, UDR0			// loading user input into R17
	cpi		R17, '+'
	brne	inc_R18_to_loop		// se for '+', essa linha será ignorada
	txs		string_begin_game
	pop		R16

	// lets begin the game

game_init:						// this label is just to make the code look organized
	push	R19					
	push	R20

	ldi		R19, 0x30
game_loop:
	call	rx_R17				// once the user types something, it will be stored in R17
	inc		R20					// my counter :3    (it doenst work bc it displays in hexa or something in the terminal)
	sbc		R17, R19			// its in ascii, so we need to convert it by subtracting.   (also, could've used subi)
	cp		R17, R18
	breq	endgame
	brlt	its_lower
its_greater:
	txs		string_greater_than
	rjmp	game_loop

its_lower:
	txs		string_less_than
	rjmp	game_loop

endgame:
	txs		string_is_equal
	call	tx_tries_R20
	pop		R20
	pop		R19
	jmp		sorteio_init	// starts game again


string_greetings_game:
	.db "Digite + para iniciar o jogo", '\n', 0
	
string_begin_game:
	.db '\n', "Jogo iniciado! Tente adivinhar o número que foi sorteado de 0 a 9.", '\n',  0, 0

string_less_than:
	.db '\n', "Tente um número maior!", '\n', 0, 0

string_greater_than:
	.db '\n', "Tente um número menor!", '\n',  0, 0

string_is_equal:
	.db '\n', "Parabéns! Você acertou", '\n',  0, 0

string_tries_begin:
	.db	'\n', "Você tentou ", 0

string_tries_end:
	.db	" vezes para acertar o número.", '\n',  0, 0




// 3 tentativas deu 0x83



// another way of sorteamento!

;	lds		R16, UCSR0A		// loading mr buffer
;	sbrc	R16, 7			// if this is clear, I dont need to verify the user input (bc there is nothing to verify)
;	rjmp	verifica		
;	inc		R18
;	rjmp	sorteio_loop
;verifica:
;	lds		R17, UDR0		we load whatever the user input is into R17
;	cpi		R17, '+'
;	breq	game_init		// if '+', game starts
;	inc		R18				// else, inc R18 and start again
;	rjmp	sorteio_loop
