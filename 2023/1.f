variable total
create clvalue 2 cells allot

: newline? ( c -- u ) 0x0a = ;
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

: find-first-digit ( c-saddr c-eaddr -- c-addr d f )
    over do
        dup c@ newline? if
            unloop 0 false exit
        then
        dup c@ digit? if 
            unloop true exit
        then
        char+
    loop

    0 false
;

: find-last-digit ( c-saddr c-eaddr -- c-addr d f )
    -1 -rot \ prepare result

    over ?do
        dup c@ newline? if
            leave
        then
        dup c@ digit? if 
            rot drop swap \ remove old digit
        then
        char+
    loop

    swap
    dup -1 = if false else true then
;

: sum-lines ( c-saddr c-eaddr -- total c-addr )
  over >r \ Save start address

  begin
      -1 cal-value-1 !
      -1 cal-value-2 !

      2dup find-first-digit if
        cal-value-1 ! drop

        2dup find-last-digit if
          cal-value-2 !
        then
      then 

      char+            \ Advance over found digit
      rot drop swap    \ Prepare stack for next iteration

      cal-value-1 @ -1 <> cal-value-2 @ -1 <> and if
        cal-value-1 @ 10 * cal-value-2 @ + \ Calculate line's number
        total @ + total ! \ Add to total
      then

      2dup swap - 0 <= \ Are we at the end?
  until

  2drop  \ Pop start/end
  total @ r> 
;

0 total !
s" /home/davide/aoc_true.txt" x-slurp-file 
over + \ save end address
sum-lines
free throw \ free address 

." Total is " . cr
bye
