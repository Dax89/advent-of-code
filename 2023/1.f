variable total
create clvalue 2 cells allot

: newline? ( c -- f ) 0x0a = ;
: cal-value-1 ( n -- v ) clvalue 0 cells + ;
: cal-value-2 ( n -- v ) clvalue 1 cells + ;

: x-slurp-file ( c-addr u -- addr n )
    r/o open-file throw >r   \ () save fileid on return stack
    r@ file-size throw d>s   \ (size) with fileid still on rstack
    dup allocate throw       \ (size addr)
    dup                      \ (size addr addr) keep addr for return
    rot                      \ (addr addr size) reorder
    r@ read-file throw       \ (addr rsize) read into buffer, consume fileid
    r> close-file throw      \ (addr rsize) close file
;

: reset-cal-values ( -- )
    -1 cal-value-1 !
    -1 cal-value-2 !
;

: update-cal-value ( v -- )
    cal-value-1 @ -1 = if
        dup cal-value-1 !
        cal-value-2 !  \ initialize val-2 as val-1 (for single valued lines)
    else
        cal-value-2 !
    then
;

: update-total ( -- )
    cal-value-1 @ -1 <> cal-value-2 @ -1 <> and if
        cal-value-1 @ 10 * cal-value-2 @ + \ Calculate line's number
        total @ + total ! \ Add to total
    then
;

: sum-lines ( c-saddr c-endaddr -- total )
    0 total !
    reset-cal-values

    swap ?do
        i c@  \ Push character

        dup newline? if
            update-total
            reset-cal-values
        else
            dup digit? if 
                update-cal-value
            then
        then

        drop  \ Pop character
    loop

    update-total \ Collect end-of-string calibrations
    total @
;

: main ( -- )
    next-arg 

    dup 0 = if
        ." Missing filename, quitting..." cr
        exit
    then

    ." Loading " 2dup type cr
    x-slurp-file 
    over +                   \ calc end address
    over swap sum-lines

    ." Total is " . cr
    free throw               \ free address 
;

main
bye
