;
; YOCTOTRO - A $120 BYTE INTRO
;

; Coding by T.M.R/Cosine


; An intro that assembles to $0770 to $088f, so executing from just
; $120 bytes of RAM with a logo and scroller. This could be made
; even smaller, but I wanted at least some pretty colours and the
; classic C64 intro "hum"!


; This source code is formatted for the ACME cross assembler from
; http://sourceforge.net/projects/acme-crossass/
; Compression is handled with Exomizer which can be downloaded at
; https://csdb.dk/release/?id=167084

; build.bat will call both to create an assembled file and then the
; crunched release version.


; Select an output filename
		!to "yoctotro.prg",cbm

; Constants
logo_col_1	= $04
logo_col_2	= $0e
scroll_len	= (scroll_end-scroll_text)-$01

; Two lines of Cosine Systems logo
		* = $0770
logo_data	!byte $6c,$e2,$e2,$6c,$e2,$fc,$7c,$fc
		!byte $7b,$7c,$61,$ff,$fb,$7b,$ff,$fb
		!byte $7b,$20,$fb,$62,$20,$fb,$62,$61
		!byte $fb,$62,$20,$e2,$e2,$7b,$ff,$fb
		!byte $7b,$ff,$e2,$fb,$7b,$fb,$62,$20

		!byte $7c,$fc,$62,$7c,$fc,$ec,$6c,$62
		!byte $ec,$e1,$61,$a0,$e1,$61,$fb,$fc
		!byte $7b,$20,$62,$fe,$7e,$62,$fe,$7e
		!byte $62,$fe,$7e,$20,$e1,$61,$fb,$fc
		!byte $7b,$a0,$e1,$e1,$61,$62,$fe,$7e

; The obligatory scrolling message
scroll_text	!scr "    "
		!scrxor $80," yoctotro "

		!scr " a $120 byte intro by t.m.r"
		!scr "   "

		!scr "S to our friends!"
scroll_end


; Main code start at $07fd
		* = $07fd
entry		sei

; Colour in the logo and scroller
		ldx #$27
screen_col_set	lda #logo_col_1
		sta $db70,x
		lda #logo_col_2
		sta $db98,x

		lda #$01
		sta $dbc0,x

		dex
		bpl screen_col_set

; Set up the SID
		ldx #$11
sid_init	lda sid_data,x
		sta $d407,x
		dex
		bpl sid_init

; A is $c6 at this point, so use it to mask the scroller
		sta $dbe7

; Wait for the start of the scroller
main_loop	lda #$f2
		jsr raster_wait

; Set scroll register for the scroller
scroll_x	lda #$00
		ora #$08
		sta $d016

; Wait for the lower border (A will between $08 and $0f)
		jsr raster_wait

; Reset the scroll register for the main screen
		lda #$08
		sta $d016

; Update the scroller
		ldx scroll_x+$01
		dex
		bpl sx_xb

; Shift the scroll area (it wraps around)
		ldy scroll_text+$00

		ldx #$00
mover		lda scroll_text+$01,x
		sta scroll_text+$00,x
		inx
		cpx #scroll_len
		bne mover

		sty scroll_text+scroll_len

		ldx #$07
sx_xb		stx scroll_x+$01

; Fade out the chars at each end of the scroller (to look pretty!)
		lda scroll_cols,x
		sta $dbe6

		txa
		eor #$07
		tax

		lda scroll_cols,x
		sta $dbc0

; Check to see if space has been pressed
		lda $dc01
		cmp #$ef
		bne main_loop

; Space has been pressed so reset the C64
		jmp $fce2


; Subroutine to wait for a specific raster line...
raster_wait	cmp $d012
		bne raster_wait

; ...then waste a few more cycles waiting for the end
		ldx #$09
		dex
		bne *-$01

		rts


; Scroller colour fade
scroll_cols	!byte $01,$0d,$03,$0e,$04,$0b,$06

; SID registers for the hum
sid_data	!byte $c6,$02,$00,$00,$21,$0f,$ff
		!byte $cc,$02,$00,$00,$21,$0f,$ff
		!byte $00,$00,$00,$0b
