section .data
    ; message de bienvenue
    welcome_msg db "Bienvenue dans le générateur de mot de passe by LucMARTIN & Léo HAIDAR B-)", 10, 10
    welcome_msg_len equ $ - welcome_msg

    ; liste des commandes disponibles
    commands_msg db "Commandes disponibles:", 10, \
                    "  simple   : Génère un mot de passe de 8 caractères (chiffres et lettres)", 10, \
                    "  medium   : Génère un mot de passe de 10 caractères (chiffres, lettres et caracteres speciaux)", 10, \
                    "  hardcore : Génère un mot de passe de 20 caractères (chiffres, lettres et caracteres speciaux)", 10, \
                    "  custom   : Génère un mot de passe sur mesure", 10, \
                    "  vault    : Affiche le vault (mot de passe sauvegardés)", 10, \
                    "  help     : Affiche cette aide", 10, \
                    "  exit     : Quitte le programme", 10, 10
    commands_msg_len equ $ - commands_msg

    ; prompt de commande
    prompt_msg db "Entrez une commande: ", 0
    prompt_msg_len equ $ - prompt_msg

    ; message de succes
    success_msg db "Mot de passe généré !", 10, 0
    success_msg_len equ $ - success_msg

    ; message commande inconnue
    unknown_cmd_msg db "Commande inconnue !", 10, 10, 0
    unknown_cmd_msg_len equ $ - unknown_cmd_msg

    newline db 10

    ; ensemble de caracteres pour simple
    allowed_chars db "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", 0
    allowed_len equ $ - allowed_chars - 1

    ; ensemble de caracteres pour medium et hardcore
    allowed_medium_chars db "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*()", 0
    allowed_medium_chars_len equ $ - allowed_medium_chars - 1

    exit_str   db "exit", 0
    exit_str_len equ $ - exit_str - 1

    simple_str db "simple", 0
    simple_str_len equ $ - simple_str - 1

    medium_str db "medium", 0
    medium_str_len equ $ - medium_str - 1

    hardcore_str db "hardcore", 0
    hardcore_str_len equ $ - hardcore_str - 1

    custom_str db "custom", 0
    custom_str_len equ $ - custom_str - 1

    help_str db "help", 0
    help_str_len equ $ - help_str - 1

    ; --- Ajouts pour le vault ---
    vault_str db "vault", 0
    vault_str_len equ $ - vault_str - 1

    vault_save_prompt db "Voulez-vous sauvegarder ce mot de passe ? (oui/non): ", 0
    vault_save_prompt_len equ $ - vault_save_prompt

    vault_name_prompt db "Entrez un nom pour le mot de passe: ", 0
    vault_name_prompt_len equ $ - vault_name_prompt

    empty_vault_msg db "Aucun mot de passe sauvegarde.", 10, 0
    empty_vault_msg_len equ $ - empty_vault_msg

    separator_str db " : ", 0
    separator_str_len equ $ - separator_str
    ; --- Fin des ajouts pour le vault ---

    custom_length_prompt db "Entrez la longueur du mot de passe custom: ", 0
    custom_length_prompt_len equ $ - custom_length_prompt

    custom_lowercase_prompt db "Inclure des lettres minuscules ? (oui/non): ", 0
    custom_lowercase_prompt_len equ $ - custom_lowercase_prompt

    custom_uppercase_prompt db "Inclure des lettres majuscules ? (oui/non): ", 0
    custom_uppercase_prompt_len equ $ - custom_uppercase_prompt

    custom_numbers_prompt db "Inclure des nombres ? (oui/non): ", 0
    custom_numbers_prompt_len equ $ - custom_numbers_prompt

    custom_special_prompt db "Inclure des caracteres speciaux ? (oui/non): ", 0
    custom_special_prompt_len equ $ - custom_special_prompt

    none_selected_msg db "Aucun caractere selectionne !", 10, 10, 0
    none_selected_msg_len equ $ - none_selected_msg

    yes_str db "oui", 0
    yes_str_len equ $ - yes_str - 1

    non_str db "non", 0
    non_str_len equ $ - non_str - 1

    lowercase_chars db "abcdefghijklmnopqrstuvwxyz", 0
    lowercase_chars_len equ $ - lowercase_chars - 1

    uppercase_chars db "ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
    uppercase_chars_len equ $ - uppercase_chars - 1

    numbers_chars db "0123456789", 0
    numbers_chars_len equ $ - numbers_chars - 1

    special_chars db "!@#$%^&*()", 0
    special_chars_len equ $ - special_chars - 1

    invalid_number_msg db "Ce n'est pas un nombre !", 10, 0
    invalid_number_msg_len equ $ - invalid_number_msg

    empty_number_msg db "Le champ ne doit pas etre vide !", 10, 0
    empty_number_msg_len equ $ - empty_number_msg

    invalid_response_msg db "Reponse invalide !", 10, 0
    invalid_response_msg_len equ $ - invalid_response_msg

section .bss
    input_buffer resb 16
    simple_password_buffer resb 9
    medium_password_buffer resb 11
    hardcore_password_buffer resb 21
    custom_charset resb 256
    custom_password_buffer resb 256
    seed resq 1

    ; --- Variables pour le vault ---
    name_input resb 64               ; tampon pour le nom saisi
    vault_storage resb 1024            ; espace mémoire pour stocker les entrées du vault
    vault_offset resq 1                ; offset courant dans vault_storage
    last_password_ptr resq 1           ; pointeur sur le dernier mot de passe généré
    last_password_len resq 1           ; longueur du dernier mot de passe généré
    ; --- Fin des variables pour le vault ---

section .text
    global _start, exit_program, display_result

_start:
    ; affichage du message de bienvenue
    mov rax, 1
    mov rdi, 1
    mov rsi, welcome_msg
    mov rdx, welcome_msg_len
    syscall

    ; affichage de la liste des commandes
    mov rax, 1
    mov rdi, 1
    mov rsi, commands_msg
    mov rdx, commands_msg_len
    syscall

main_loop:
    ; affichage du prompt de commande
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt_msg
    mov rdx, prompt_msg_len
    syscall

    ; lecture de la commande entrée
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buffer
    mov rdx, 16
    syscall
    mov rbx, rax
    mov rdi, input_buffer
trim_loop:
    cmp rbx, 0
    je after_trim
    cmp byte [rdi], 10
    jne not_newline
    mov byte [rdi], 0
not_newline:
    inc rdi
    dec rbx
    jmp trim_loop
after_trim:
    ; vérification de la commande exit
    mov rdi, input_buffer
    mov rsi, exit_str
    mov rcx, exit_str_len
    repe cmpsb
    cmp rcx, 0
    je exit_program

    ; vérification de la commande simple
    mov rdi, input_buffer
    mov rsi, simple_str
    mov rcx, simple_str_len
    repe cmpsb
    cmp rcx, 0
    je gen_simple

    ; vérification de la commande medium
    mov rdi, input_buffer
    mov rsi, medium_str
    mov rcx, medium_str_len
    repe cmpsb
    cmp rcx, 0
    je gen_medium

    ; vérification de la commande hardcore
    mov rdi, input_buffer
    mov rsi, hardcore_str
    mov rcx, hardcore_str_len
    repe cmpsb
    cmp rcx, 0
    je gen_hardcore

    ; vérification de la commande custom
    mov rdi, input_buffer
    mov rsi, custom_str
    mov rcx, custom_str_len
    repe cmpsb
    cmp rcx, 0
    je gen_custom

    ; vérification de la commande help
    mov rdi, input_buffer
    mov rsi, help_str
    mov rcx, help_str_len
    repe cmpsb
    cmp rcx, 0
    je print_help

    ; vérification de la commande vault
    mov rdi, input_buffer
    mov rsi, vault_str
    mov rcx, vault_str_len
    repe cmpsb
    cmp rcx, 0
    je show_vault

    ; commande inconnue
    mov rax, 1
    mov rdi, 1
    mov rsi, unknown_cmd_msg
    mov rdx, unknown_cmd_msg_len
    syscall
    jmp main_loop

print_help:
    ; affiche la liste des commandes
    mov rax, 1
    mov rdi, 1
    mov rsi, commands_msg
    mov rdx, commands_msg_len
    syscall
    jmp main_loop

gen_simple:
    ; génération du mot de passe simple
    rdtsc
    mov rbx, rdx
    shl rbx, 32
    or rbx, rax
    mov [seed], rbx
    mov rcx, 8
    mov rsi, simple_password_buffer
simple_loop:
    mov rax, [seed]
    mov rbx, 1103515245
    mul rbx
    add rax, 12345
    mov [seed], rax
    shr rax, 16
    mov rbx, allowed_len
    xor rdx, rdx
    div rbx
    mov rbx, allowed_chars
    add rbx, rdx
    mov dl, byte [rbx]
    mov byte [rsi], dl
    inc rsi
    loop simple_loop
    mov byte [rsi], 0
    ; sauvegarde du pointeur et de la longueur pour le vault
    mov qword [last_password_ptr], simple_password_buffer
    mov qword [last_password_len], 8
    ; affichage du résultat
    mov rdi, simple_password_buffer
    mov rsi, 8
    call display_result
    call vault_prompt
    jmp main_loop

gen_medium:
    ; génération du mot de passe medium
    rdtsc
    mov rbx, rdx
    shl rbx, 32
    or rbx, rax
    mov [seed], rbx
    mov rcx, 10
    mov rsi, medium_password_buffer
medium_loop:
    mov rax, [seed]
    mov rbx, 1103515245
    mul rbx
    add rax, 12345
    mov [seed], rax
    shr rax, 16
    mov rbx, allowed_medium_chars_len
    xor rdx, rdx
    div rbx
    mov rbx, allowed_medium_chars
    add rbx, rdx
    mov dl, byte [rbx]
    mov byte [rsi], dl
    inc rsi
    loop medium_loop
    mov byte [rsi], 0
    mov qword [last_password_ptr], medium_password_buffer
    mov qword [last_password_len], 10
    mov rdi, medium_password_buffer
    mov rsi, 10
    call display_result
    call vault_prompt
    jmp main_loop

gen_hardcore:
    ; génération du mot de passe hardcore
    rdtsc
    mov rbx, rdx
    shl rbx, 32
    or rbx, rax
    mov [seed], rbx
    mov rcx, 20
    mov rsi, hardcore_password_buffer
hardcore_loop:
    mov rax, [seed]
    mov rbx, 1103515245
    mul rbx
    add rax, 12345
    mov [seed], rax
    shr rax, 16
    mov rbx, allowed_medium_chars_len
    xor rdx, rdx
    div rbx
    mov rbx, allowed_medium_chars
    add rbx, rdx
    mov dl, byte [rbx]
    mov byte [rsi], dl
    inc rsi
    loop hardcore_loop
    mov byte [rsi], 0
    mov qword [last_password_ptr], hardcore_password_buffer
    mov qword [last_password_len], 20
    mov rdi, hardcore_password_buffer
    mov rsi, 20
    call display_result
    call vault_prompt
    jmp main_loop

gen_custom:
    ; génération du mot de passe custom
custom_length_input:
    mov rax, 1
    mov rdi, 1
    mov rsi, custom_length_prompt
    mov rdx, custom_length_prompt_len
    syscall
    ; lecture de la longueur custom
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buffer
    mov rdx, 16
    syscall
    mov rbx, rax
    mov rdi, input_buffer
custom_length_trim:
    cmp rbx, 0
    je custom_length_conv
    cmp byte [rdi], 10
    jne custom_length_not_newline
    mov byte [rdi], 0
custom_length_not_newline:
    inc rdi
    dec rbx
    jmp custom_length_trim
custom_length_conv:
    ; vérifie si le champ est vide
    cmp byte [input_buffer], 0
    je custom_empty_input
    xor rax, rax
    xor rcx, rcx
custom_conv_loop:
    mov bl, [input_buffer + rcx]
    cmp bl, 0
    je custom_conv_done
    cmp bl, '0'
    jb custom_conv_invalid
    cmp bl, '9'
    ja custom_conv_invalid
    imul rax, rax, 10
    sub bl, '0'
    movzx rbx, bl
    add rax, rbx
    inc rcx
    jmp custom_conv_loop
custom_conv_invalid:
    mov rax, 1
    mov rdi, 1
    mov rsi, invalid_number_msg
    mov rdx, invalid_number_msg_len
    syscall
    jmp custom_length_input
custom_conv_done:
    mov r9, rax

    ; initialisation du charset custom
    mov r8, custom_charset

    ; demande pour lettres minuscules
lowercase_loop:
    mov rax, 1
    mov rdi, 1
    mov rsi, custom_lowercase_prompt
    mov rdx, custom_lowercase_prompt_len
    syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buffer
    mov rdx, 16
    syscall
    mov rbx, rax
    mov rdi, input_buffer
lowercase_trim:
    cmp rbx, 0
    je lowercase_check
    cmp byte [rdi], 10
    jne lowercase_not_newline
    mov byte [rdi], 0
lowercase_not_newline:
    inc rdi
    dec rbx
    jmp lowercase_trim
lowercase_check:
    mov rdi, input_buffer
    mov rsi, yes_str
    mov rcx, yes_str_len
    repe cmpsb
    cmp rcx, 0
    je set_lowercase_yes
    mov rdi, input_buffer
    mov rsi, non_str
    mov rcx, non_str_len
    repe cmpsb
    cmp rcx, 0
    je set_lowercase_no
    ; ce commantaire contient une faulte intentionelle
    mov rax, 1
    mov rdi, 1
    mov rsi, invalid_response_msg
    mov rdx, invalid_response_msg_len
    syscall
    jmp lowercase_loop
set_lowercase_yes:
    mov rdi, r8
    mov rcx, lowercase_chars_len
    mov rsi, lowercase_chars
    rep movsb
    mov r8, rdi
set_lowercase_no:

    ; demande pour lettres majuscules
uppercase_loop:
    mov rax, 1
    mov rdi, 1
    mov rsi, custom_uppercase_prompt
    mov rdx, custom_uppercase_prompt_len
    syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buffer
    mov rdx, 16
    syscall
    mov rbx, rax
    mov rdi, input_buffer
uppercase_trim:
    cmp rbx, 0
    je uppercase_check
    cmp byte [rdi], 10
    jne uppercase_not_newline
    mov byte [rdi], 0
uppercase_not_newline:
    inc rdi
    dec rbx
    jmp uppercase_trim
uppercase_check:
    mov rdi, input_buffer
    mov rsi, yes_str
    mov rcx, yes_str_len
    repe cmpsb
    cmp rcx, 0
    je set_uppercase_yes
    mov rdi, input_buffer
    mov rsi, non_str
    mov rcx, non_str_len
    repe cmpsb
    cmp rcx, 0
    je set_uppercase_no
    mov rax, 1
    mov rdi, 1
    mov rsi, invalid_response_msg
    mov rdx, invalid_response_msg_len
    syscall
    jmp uppercase_loop
set_uppercase_yes:
    mov rdi, r8
    mov rcx, uppercase_chars_len
    mov rsi, uppercase_chars
    rep movsb
    mov r8, rdi
set_uppercase_no:

    ; demande pour nombres
numbers_loop:
    mov rax, 1
    mov rdi, 1
    mov rsi, custom_numbers_prompt
    mov rdx, custom_numbers_prompt_len
    syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buffer
    mov rdx, 16
    syscall
    mov rbx, rax
    mov rdi, input_buffer
numbers_trim:
    cmp rbx, 0
    je numbers_check
    cmp byte [rdi], 10
    jne numbers_not_newline
    mov byte [rdi], 0
numbers_not_newline:
    inc rdi
    dec rbx
    jmp numbers_trim
numbers_check:
    mov rdi, input_buffer
    mov rsi, yes_str
    mov rcx, yes_str_len
    repe cmpsb
    cmp rcx, 0
    je set_numbers_yes
    mov rdi, input_buffer
    mov rsi, non_str
    mov rcx, non_str_len
    repe cmpsb
    cmp rcx, 0
    je set_numbers_no
    mov rax, 1
    mov rdi, 1
    mov rsi, invalid_response_msg
    mov rdx, invalid_response_msg_len
    syscall
    jmp numbers_loop
set_numbers_yes:
    mov rdi, r8
    mov rcx, numbers_chars_len
    mov rsi, numbers_chars
    rep movsb
    mov r8, rdi
set_numbers_no:

    ; demande pour caracteres speciaux
special_loop:
    mov rax, 1
    mov rdi, 1
    mov rsi, custom_special_prompt
    mov rdx, custom_special_prompt_len
    syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buffer
    mov rdx, 16
    syscall
    mov rbx, rax
    mov rdi, input_buffer
special_trim:
    cmp rbx, 0
    je special_check
    cmp byte [rdi], 10
    jne special_not_newline
    mov byte [rdi], 0
special_not_newline:
    inc rdi
    dec rbx
    jmp special_trim
special_check:
    mov rdi, input_buffer
    mov rsi, yes_str
    mov rcx, yes_str_len
    repe cmpsb
    cmp rcx, 0
    je set_special_yes
    mov rdi, input_buffer
    mov rsi, non_str
    mov rcx, non_str_len
    repe cmpsb
    cmp rcx, 0
    je set_special_no
    mov rax, 1
    mov rdi, 1
    mov rsi, invalid_response_msg
    mov rdx, invalid_response_msg_len
    syscall
    jmp special_loop
set_special_yes:
    mov rdi, r8
    mov rcx, special_chars_len
    mov rsi, special_chars
    rep movsb
    mov r8, rdi
set_special_no:
    ; vérifie que le charset custom n'est pas vide
    mov rax, r8
    sub rax, custom_charset
    cmp rax, 0
    je custom_no_charset
    ; génération du mot de passe custom
    mov r10, rax
    rdtsc
    mov rbx, rdx
    shl rbx, 32
    or rbx, rax
    mov [seed], rbx
    xor rcx, rcx
custom_gen_loop:
    cmp rcx, r9
    jge custom_gen_done
    mov rax, [seed]
    mov rbx, 1103515245
    mul rbx
    add rax, 12345
    mov [seed], rax
    shr rax, 16
    mov rbx, r10
    xor rdx, rdx
    div rbx
    mov rbx, custom_charset
    add rbx, rdx
    mov dl, byte [rbx]
    mov byte [custom_password_buffer + rcx], dl
    inc rcx
    jmp custom_gen_loop
custom_gen_done:
    mov byte [custom_password_buffer + rcx], 0
    mov qword [last_password_ptr], custom_password_buffer
    mov qword [last_password_len], r9
    mov rdi, custom_password_buffer
    mov rsi, r9
    call display_result
    call vault_prompt
    jmp main_loop

custom_empty_input:
    ; champ vide pour la longueur custom
    mov rax, 1
    mov rdi, 1
    mov rsi, empty_number_msg
    mov rdx, empty_number_msg_len
    syscall
    jmp custom_length_input

custom_no_charset:
    ; aucun charset sélectionné
    mov rax, 1
    mov rdi, 1
    mov rsi, none_selected_msg
    mov rdx, none_selected_msg_len
    syscall
    jmp main_loop

exit_program:
    ; fin du programme
    mov rax, 60
    xor rdi, rdi
    syscall

; fonction d'affichage du résultat
; rdi = pointer to password, rsi = length of password
display_result:
    mov r8, rdi   ; sauvegarde du pointer
    mov r9, rsi   ; sauvegarde de la longueur
    ; affichage d'un saut de ligne
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    ; affichage du message de succès
    mov rax, 1
    mov rdi, 1
    mov rsi, success_msg
    mov rdx, success_msg_len
    syscall
    ; affichage d'un saut de ligne
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    ; affichage du mot de passe
    mov rax, 1
    mov rdi, 1
    mov rsi, r8
    mov rdx, r9
    syscall
    ; affichage de deux sauts de ligne
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    ret

; --- Fonctionnalité Vault ---
; Demande à l'utilisateur s'il veut sauvegarder le mot de passe, et si oui,
; lui demande un nom et enregistre l'entrée dans vault_storage.
vault_prompt:
    cld  ; efface le flag de direction pour lodsb/stosb
    ; affiche le prompt de sauvegarde
    mov rax, 1
    mov rdi, 1
    mov rsi, vault_save_prompt
    mov rdx, vault_save_prompt_len
    syscall

    ; lecture de la réponse dans input_buffer
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buffer
    mov rdx, 16
    syscall

    ; suppression des sauts de ligne
    mov rbx, rax
    mov rdi, input_buffer
vault_prompt_trim:
    cmp rbx, 0
    je vault_prompt_after_trim
    cmp byte [rdi], 10
    jne vault_prompt_not_newline
    mov byte [rdi], 0
vault_prompt_not_newline:
    inc rdi
    dec rbx
    jmp vault_prompt_trim
vault_prompt_after_trim:

    ; vérifie si la réponse est "oui"
    mov rdi, input_buffer
    mov rsi, yes_str
    mov rcx, yes_str_len
    repe cmpsb
    cmp rcx, 0
    jne vault_prompt_end   ; si ce n'est pas "oui", on ne sauvegarde pas

    ; demande le nom pour le mot de passe
    mov rax, 1
    mov rdi, 1
    mov rsi, vault_name_prompt
    mov rdx, vault_name_prompt_len
    syscall

    ; lecture du nom dans name_input
    mov rax, 0
    mov rdi, 0
    mov rsi, name_input
    mov rdx, 64
    syscall

    ; suppression des sauts de ligne dans le nom
    mov rbx, rax
    mov rdi, name_input
vault_name_trim:
    cmp rbx, 0
    je vault_name_trim_done
    cmp byte [rdi], 10
    jne vault_name_not_newline
    mov byte [rdi], 0
vault_name_not_newline:
    inc rdi
    dec rbx
    jmp vault_name_trim
vault_name_trim_done:

    ; Construction de l'entrée du vault : [nom] " : " [motdepasse] "\n"
    ; Récupère l'offset courant dans vault_storage
    mov rax, [vault_offset]
    mov rdi, vault_storage
    add rdi, rax

    cld  ; s'assurer que DF est à 0
    ; copie le nom depuis name_input
    mov rsi, name_input
vault_copy_name:
    lodsb
    cmp al, 0
    je vault_copy_separator
    stosb
    jmp vault_copy_name

vault_copy_separator:
    mov rsi, separator_str
vault_copy_sep_loop:
    lodsb
    cmp al, 0
    je vault_copy_password
    stosb
    jmp vault_copy_sep_loop

vault_copy_password:
    ; copie le mot de passe depuis last_password_ptr (mot de passe déjà sauvegardé)
    mov rsi, [last_password_ptr]
    mov rcx, [last_password_len]
vault_copy_pass_loop:
    cmp rcx, 0
    je vault_copy_newline
    mov al, byte [rsi]
    stosb
    inc rsi
    dec rcx
    jmp vault_copy_pass_loop

vault_copy_newline:
    ; ajoute un saut de ligne à la fin de l'entrée
    mov al, 10
    stosb

    ; mise à jour de vault_offset : nouvelle position = rdi - vault_storage
    mov rax, vault_storage
    sub rdi, rax
    mov [vault_offset], rdi

vault_prompt_end:
    ret

; Affiche toutes les entrées sauvegardées dans le vault
show_vault:
    mov rax, [vault_offset]
    cmp rax, 0
    jne vault_display
    mov rax, 1
    mov rdi, 1
    mov rsi, empty_vault_msg
    mov rdx, empty_vault_msg_len
    syscall
    jmp main_loop

vault_display:
    mov rax, 1
    mov rdi, 1
    mov rsi, vault_storage
    mov rdx, [vault_offset]
    syscall
    jmp main_loop
