variable total

: digit-pair ( val c-addr n -- ) , , , ;

create ldigits 1 s" one" digit-pair
               2 s" two" digit-pair
               3 s" three" digit-pair
               4 s" four" digit-pair
               5 s" five" digit-pair
               6 s" six" digit-pair
               7 s" seven" digit-pair
               8 s" eight" digit-pair
               9 s" nine" digit-pair

here constant ldigits_end

: digit-name ( entry -- name u ) 2@ ;
: digit-name-len ( entry -- len ) @ ;
: digit-value ( entry -- val ) 2 cells + @ ;

: is-digit? ( c-addr u -- c-addr' u' d t | f ) 
    dup 0 = if 0 false exit then \ Check if string is empty

    ldigits_end ldigits do
        2dup i digit-name string-prefix? if
            i digit-name-len 1 - /string \ Handle cases like 'oneight'
            i digit-value
            true
            unloop exit
        then
    3 cells +loop

    \ Fallback to default implementation
    over c@ digit? if
        -rot 1 /string rot
        true
    else
        false
    then
;

create clvalue 2 cells allot

: newline? ( c -- f ) 0x0a = ;
: cal-value-1 ( n -- v ) clvalue 0 cells + ;
: cal-value-2 ( n -- v ) clvalue 1 cells + ;
: reset-cal-values ( -- ) -1 cal-value-1 ! -1 cal-value-2 ! ;

: x-slurp-file ( c-addr u -- addr n )
    r/o open-file throw >r   \ () save fileid on return stack
    r@ file-size throw d>s   \ (size) with fileid still on rstack
    dup allocate throw       \ (size addr)
    dup                      \ (size addr addr) keep addr for return
    rot                      \ (addr addr size) reorder
    r@ read-file throw       \ (addr rsize) read into buffer, consume fileid
    r> close-file throw      \ (addr rsize) close file
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

: sum-lines ( c-saddr n -- total )
    0 total !
    reset-cal-values

    begin
       over c@ newline? if
            update-total
            reset-cal-values
            1 /string
       else
           is-digit? if
               update-cal-value
           else
               1 /string
           then
       then

       dup 0 =
    until

    2drop
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
    over swap sum-lines

    ." Total is " . cr
    free throw               \ free address 
;


main
bye
