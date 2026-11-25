    # PURPOSE:
    #     This program is meant to be an example of
    #     what GUI programs look like written with the
    #     GTK 4 library.
    #
    # INPUT:
    #     The user can only click on the button or
    #     close the window.
    #
    # OUTPUT:
    #     The application will close.
    #
    # PROCESS:
    #     If the user clicks on the button, the
    #     program will display a dialog asking if they
    #     are sure. If they click Yes, the application
    #     ends. Otherwise it will continue running.
    #
    .section .note.GNU-stack,"",@progbits

    .section .rodata
        # GTK definitions:
        #     These were found in the GTK and GLib
        #     header files for the C language and
        #     converted into their assembly
        #     equivalents.
        #
        .equ G_APPLICATION_DEFAULT_FLAGS, 0
        .equ NULL, 0        # Standard definition of
                            # NULL.

        signal_activate:    # GTK signal names.
            .ascii "activate\0"
        signal_clicked:
            .ascii "clicked\0"

        # --- Application-specific definitions --- #
        #
        app_id:             # Application information.
            .ascii "org.example.GtkExample\0"
        app_title:
            .ascii "GTK Example Program\0"
                            # Text for buttons and
        button_quit_text:   # windows.
            .ascii "I Want to Quit the GTK Example\0"
        quit_question:
            .ascii "Are you sure you want to quit?\0"
        answer_yes:
            .ascii "Yes\0"
        answer_no:
            .ascii "No\0"

        .equ YES, 0         # Positions of the answers.
        .equ NO,  1
        .equ WINDOW_WIDTH,  400
        .equ WINDOW_HEIGHT, 100

    # A list of the addresses of the answers, ended by
    # NULL, as GTK wants it. A table of addresses goes
    # in .data.rel.ro: the dynamic linker writes the
    # real addresses when the program starts (it is a
    # PIE), and then makes the table read-only.
    #
    .section .data.rel.ro, "aw"
        .balign 8
        answers:
            .quad answer_yes
            .quad answer_no
            .quad NULL

    .section .text
    # main(argc, argv): create the application, connect
    # our activate_handler to its "activate" signal and
    # run it. Its result is the exit status.
    #
        .globl main
        .type  main, @function
main:
    pushq %rbp
    movq  %rsp, %rbp
    pushq %rbx              # Save the callee-saved
    pushq %r12              # registers we use. Three
    pushq %r13              # pushes plus 8 more bytes
    subq  $8, %rsp          # keep %rsp aligned to 16.

    movq  %rdi, %rbx        # Argc.
    movq  %rsi, %r12        # Argv.

                            # Create the application.
    leaq  app_id(%rip), %rdi
    movq  $G_APPLICATION_DEFAULT_FLAGS, %rsi
    call  gtk_application_new@PLT
    movq  %rax, %r13        # Save its pointer.

    # Have GTK call our activate_handler function when
    # the application starts. g_signal_connect is a C
    # macro, so we call the function behind it, which
    # has two more parameters (both 0 here).
    #
    movq  %r13, %rdi        # Object to listen to.
    leaq  signal_activate(%rip), %rsi  # Signal name.
    leaq  activate_handler(%rip), %rdx # Function to
                            # call.
    movq  $NULL, %rcx       # Extra data to pass to our
                            # function (none).
    movq  $NULL, %r8        # Function to free it.
    movq  $0, %r9           # Flags.
    call  g_signal_connect_data@PLT

    # Transfer control to GTK. Everything that happens
    # from here out is in reaction to user events,
    # which call signal handlers. It returns when the
    # last window of the application is closed.
    #
    movq  %r13, %rdi
    movl  %ebx, %esi        # Argc is an int.
    movq  %r12, %rdx
    call  g_application_run@PLT
    movl  %eax, %ebx        # The exit status.

    movq  %r13, %rdi        # Free the application.
    call  g_object_unref@PLT

    movl  %ebx, %eax        # Return the status.
    addq  $8, %rsp
    popq  %r13
    popq  %r12
    popq  %rbx
    popq  %rbp
    ret

    # activate_handler(app, data): create the window
    # and its button.
    #
    .type activate_handler, @function
activate_handler:
    pushq %rbp
    movq  %rsp, %rbp
    pushq %rbx
    pushq %r12

                            # Create the window.
    call  gtk_application_window_new@PLT  # (app is
    movq  %rax, %rbx        # already in %rdi.)

    movq  %rbx, %rdi
    leaq  app_title(%rip), %rsi
    call  gtk_window_set_title@PLT

    movq  %rbx, %rdi
    movq  $WINDOW_WIDTH, %rsi
    movq  $WINDOW_HEIGHT, %rdx
    call  gtk_window_set_default_size@PLT

                            # Create the button.
    leaq  button_quit_text(%rip), %rdi
    call  gtk_button_new_with_label@PLT
    movq  %rax, %r12

    movq  %rbx, %rdi        # Put the button inside
    movq  %r12, %rsi        # the window.
    call  gtk_window_set_child@PLT

    # Have GTK call our click_handler function when
    # the button is clicked, with the window as the
    # extra data.
    #
    movq  %r12, %rdi
    leaq  signal_clicked(%rip), %rsi
    leaq  click_handler(%rip), %rdx
    movq  %rbx, %rcx
    movq  $NULL, %r8
    movq  $0, %r9
    call  g_signal_connect_data@PLT

    movq  %rbx, %rdi        # Show the window.
    call  gtk_window_present@PLT

    popq  %r12
    popq  %rbx
    popq  %rbp
    ret

    # click_handler(button, window): ask if the user
    # is sure. The answer arrives later, in
    # response_handler.
    #
    .type click_handler, @function
click_handler:
    pushq %rbp
    movq  %rsp, %rbp
    pushq %rbx
    pushq %r12
    movq  %rsi, %r12        # The window.

    # Create the "Are you sure" dialog. Like printf,
    # gtk_alert_dialog_new takes a format and a
    # variable number of parameters, so %al = 0.
    #
    leaq  quit_question(%rip), %rdi
    movq  $0, %rax
    call  gtk_alert_dialog_new@PLT
    movq  %rax, %rbx

    movq  %rbx, %rdi        # Its buttons.
    leaq  answers(%rip), %rsi
    call  gtk_alert_dialog_set_buttons@PLT

    movq  %rbx, %rdi        # Return means Yes,
    movq  $YES, %rsi        # Escape means No.
    call  gtk_alert_dialog_set_default_button@PLT
    movq  %rbx, %rdi
    movq  $NO, %rsi
    call  gtk_alert_dialog_set_cancel_button@PLT

    # Show it over the window. GTK doesn't wait for
    # the answer: it calls response_handler when the
    # user clicks on a button, with the window as the
    # extra data.
    #
    movq  %rbx, %rdi        # The dialog.
    movq  %r12, %rsi        # Its parent window.
    movq  $NULL, %rdx       # No way to cancel it.
    leaq  response_handler(%rip), %rcx
    movq  %r12, %r8
    call  gtk_alert_dialog_choose@PLT

    movq  %rbx, %rdi        # We don't need the dialog
    call  g_object_unref@PLT  # any more: GTK keeps it
                            # until the user answers.
    popq  %r12
    popq  %rbx
    popq  %rbp
    ret

    # response_handler(dialog, result, window): read
    # the answer and end the application on Yes.
    #
    .type response_handler, @function
response_handler:
    pushq %rbp
    movq  %rsp, %rbp
    pushq %rbx              # Two pushes keep %rsp
    pushq %r12              # aligned to 16.
    movq  %rdx, %r12        # The window.

                            # Which button? (%rdi has
    movq  $NULL, %rdx       # the dialog and %rsi the
                            # result already.)
    call  gtk_alert_dialog_choose_finish@PLT
    cmpl  $YES, %eax        # It returns an int.
    jne   end_response

    movq  %r12, %rdi        # Find the application of
    call  gtk_window_get_application@PLT  # the window
    movq  %rax, %rdi        # and tell it to leave its
    call  g_application_quit@PLT  # event loop.
end_response:
    popq  %r12
    popq  %rbx
    popq  %rbp
    ret
