; ParkingSystem
.model small
.stack 100h

.data
    ; Menu strings
    menu    db '*************** PARKING MANAGEMENT SYSTEM ***************$'
    menu1   db 'Press 1 for van (Fee: 500)$'
    menu2   db 'Press 2 for Car (Fee: 300)$'
    menu3   db 'Press 3 for Bus (Fee: 400)$'
    menu4   db 'Press 4 to Show Record$'
    menu5   db 'Press 5 to Delete Record$'
    menu6   db 'Press 6 to Remove a Vehicle$'
    menu7   db 'Press 7 to Exit$'

    ; Messages
    msg1    db 'Parking is Full! Maximum 8 vehicles allowed.$'
    msg2    db 'Invalid input! Please try again.$'
    msg3    db 'Vehicle added successfully!$'
    msg4    db '*** Record deleted successfully ***$'
    msg5    db 'Total Amount Collected: $'
    msg6    db 'Total Vehicles Parked: $'
    msg7    db 'Vans: $'
    msg8    db 'Cars: $'
    msg9    db 'Buses: $'
    msg10   db 'Available Space: $'
    msg11   db 'Thank you for using Parking System!$'
    msg12   db 'Press any key to continue...$'
    msg13   db 'Select vehicle to remove (1=Van, 2=Car, 3=Bus): $'

    msg14   db 'No vehicle of this type in park!$'
    msg15   db 'Vehicle removed successfully!$'

    ; Variables
    amount      dw 0        ; Total amount collected (word)
    total_count db 0        ; Total vehicles count (0-8)
    vans        db 0        ; vans count
    cars        db 0        ; Car count
    buses       db 0        ; Bus count
    MAX_CAPACITY equ 8      ; Maximum parking capacity

.code
main proc
    mov ax, @data
    mov ds, ax

main_loop:
    call display_menu
    call get_choice

    ; Process choice (AL holds the user's key)
    cmp al, '1'
    je add_van
    cmp al, '2'
    je add_car
    cmp al, '3'
    je add_bus
    cmp al, '4'
    je show_record
    cmp al, '5'
    je delete_record
    
   cmp al, '6'
   jne not_remove        ; short jump OK
   jmp remove_vehicle    ; long jump OK
   not_remove:
   
   cmp al, '7'
   jne not_exit
   jmp exit_program
not_exit:
    
    ; Invalid input
    mov dx, offset msg2
    mov ah, 9
    int 21h
    call new_line
    call wait_keypress
    jmp main_loop


;------------------------Add Vehicles------------------------
add_van:
    mov ax, 500
    call add_vehicle
    jmp main_loop

add_car:
    mov ax, 300
    call add_vehicle
    jmp main_loop

add_bus:
    mov ax, 400
    call add_vehicle
    jmp main_loop

;------------------------Display Record------------------------
show_record:
    call display_record
    jmp main_loop

;------------------------Delete Record------------------------
delete_record:
    call reset_record
    jmp main_loop


;------------------------Procedures------------------------

; Display Menu
display_menu proc
    call clear_screen
    mov dx, offset menu
    mov ah, 9
    int 21h
    call new_line
    call new_line

    mov dx, offset menu1
    mov ah, 9
    int 21h
    call new_line
    mov dx, offset menu2
    mov ah, 9
    int 21h
    call new_line
    mov dx, offset menu3
    mov ah, 9
    int 21h
    call new_line
    mov dx, offset menu4
    mov ah, 9
    int 21h
    call new_line
    mov dx, offset menu5
    mov ah, 9
    int 21h
    call new_line
    mov dx, offset menu6
    mov ah, 9
    int 21h
    call new_line
    mov dx, offset menu7
    mov ah, 9
    int 21h
    call new_line
    call new_line
    ret
display_menu endp

; Get user choice
get_choice proc
    mov ah, 1
    int 21h          ; AL = key pressed
    mov bl, al       ; save user's key in BL
    call new_line    ; this may clobber AL
    mov al, bl       ; restore user's key
    ret
get_choice endp

; Add vehicle procedure
add_vehicle proc
    ; Check parking capacity: if total_count >= MAX_CAPACITY then full
    mov bl, total_count
    cmp bl, MAX_CAPACITY
    jae parking_full

    ; Add amount
    add amount, ax

    ; Determine vehicle type (AX contains fee: 500/300/400)
    cmp ax, 500
    je is_van
    cmp ax, 300
    je is_car
    cmp ax, 400
    je is_bus

is_van:
    inc vans
    jmp finish_add
is_car:
    inc cars
    jmp finish_add
is_bus:
    inc buses
finish_add:
    inc total_count
    ; Success message
    mov dx, offset msg3
    mov ah, 9
    int 21h
    call new_line
    call wait_keypress
    ret

parking_full:
    mov dx, offset msg1
    mov ah, 9
    int 21h
    call new_line
    call wait_keypress
    ret
add_vehicle endp

;------------------------Remove Vehicle------------------------
remove_vehicle:
    call clear_screen
    
    ; Display header
    mov dx, offset menu
    mov ah, 9
    int 21h
    call new_line
    call new_line

    ; Display removal prompt
    mov dx, offset msg13
    mov ah, 9
    int 21h
    call new_line

   ; Get user choice
     mov ah, 1
      int 21h      ; AL = key pressed
      mov bl, al   ; save user's key
      call new_line
      mov al, bl   ; restore key
      
      
    ; Process choice
    cmp al, '1'
    je remove_van_type
    cmp al, '2'
    je remove_car_type
    cmp al, '3'
    je remove_bus_type

    ; Invalid input
    mov dx, offset msg2
    mov ah, 9
    int 21h
    call new_line
    call wait_keypress
    jmp main_loop

remove_van_type:
    mov bl, vans
    cmp bl, 0
    jle no_vehicle_error
    dec vans
    sub amount, 500
    dec total_count
    jmp removed_success

remove_car_type:
    mov bl, cars
    cmp bl, 0
    jle no_vehicle_error
    dec cars
    sub amount, 300
    dec total_count
    jmp removed_success

remove_bus_type:
    mov bl, buses
    cmp bl, 0
    jle no_vehicle_error
    dec buses
    sub amount, 400
    dec total_count
    jmp removed_success

no_vehicle_error:
    mov dx, offset msg14
    mov ah, 9
    int 21h
    call new_line
    call wait_keypress
    jmp main_loop

removed_success:
    mov dx, offset msg15
    mov ah, 9
    int 21h
    call new_line
    call wait_keypress
    jmp main_loop

; Display record
display_record proc
    call clear_screen
    mov dx, offset menu
    mov ah, 9
    int 21h
    call new_line
    call new_line

    ; Total amount
    mov dx, offset msg5
    mov ah, 9
    int 21h
    mov ax, amount
    call print_number
    call new_line

    ; Total vehicles
    mov dx, offset msg6
    mov ah, 9
    int 21h
    mov al, total_count
    mov ah, 0
    call print_number
    call new_line

    ; Available space
    mov dx, offset msg10
    mov ah, 9
    int 21h
    mov al, MAX_CAPACITY
    sub al, total_count
    mov ah, 0
    call print_number
    call new_line
    call new_line

    ; Vehicle breakdown
    mov dx, offset msg7
    mov ah, 9
    int 21h
    mov al, vans
    mov ah, 0
    call print_number
    call new_line

    mov dx, offset msg8
    mov ah, 9
    int 21h
    mov al, cars
    mov ah, 0
    call print_number
    call new_line

    mov dx, offset msg9
    mov ah, 9
    int 21h
    mov al, buses
    mov ah, 0
    call print_number
    call new_line
    call new_line

    call wait_keypress
    ret
display_record endp

; Reset all records
reset_record proc
    mov amount, 0
    mov total_count, 0
    mov vans, 0
    mov cars, 0
    mov buses, 0
    mov dx, offset msg4
    mov ah, 9
    int 21h
    call new_line
    call wait_keypress
    ret
reset_record endp


;------------------------Exit Program------------------------
exit_program:
    call display_exit_message
    mov ah, 4ch
    int 21h


; Display exit message
display_exit_message proc
    call clear_screen
    mov dx, offset msg11
    mov ah, 9
    int 21h
    call new_line
    ret
display_exit_message endp

; Print number procedure (supports AX > 255)
print_number proc
    push ax
    push bx
    push cx
    push dx
    push si

    mov bx, 10
    xor cx, cx

    cmp ax, 0
    jne pn_not_zero
    mov dl, '0'
    mov ah, 2
    int 21h
    jmp pn_end

pn_not_zero:
pn_push_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne pn_push_loop

pn_pop_loop:
    pop dx
    add dl, '0'
    mov ah, 2
    int 21h
    loop pn_pop_loop

pn_end:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_number endp

; New line
new_line proc
    mov dl, 13
    mov ah, 2
    int 21h
    mov dl, 10
    mov ah, 2
    int 21h
    ret
new_line endp

; Wait for keypress
wait_keypress proc
    call new_line
    mov dx, offset msg12
    mov ah, 9
    int 21h
    mov ah, 1
    int 21h
    call new_line
    ret
wait_keypress endp


; Clear screen
clear_screen proc
    mov ax, 0600h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    mov ah, 2
    mov bh, 0
    mov dx, 0000h
    int 10h
    ret
clear_screen endp

main endp
end main