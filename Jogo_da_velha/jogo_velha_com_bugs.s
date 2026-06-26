# =========================================================================
# Jogo da Velha (Tic-Tac-Toe) em RISC-V para RARS
#
# Este programa DEVERIA implementar um jogo da velha para dois jogadores
# (X e O) no terminal, mas contem EXATAMENTE 5 ERROS em pontos diferentes
# do codigo (todos na secao .text). O programa monta e executa, pede as
# jogadas, mas se comporta de forma incorreta.
#
# Sua tarefa: encontrar e corrigir os 5 erros, deixando o jogo funcional
# (a saida deve bater com a do exemplo fornecido no enunciado).
# NAO altere a secao .data nem o texto das mensagens.
#
# Entrada de uma jogada: Letra da LINHA (A, B ou C) + numero da COLUNA
#   (1, 2 ou 3). Exemplos validos: A1, A2, A3, B1, B2, B3, C1, C2, C3.
# Marcas internas do tabuleiro: 0 = vazio, 1 = X, 2 = O.
# Rode com a flag 'sm' (start at main). Pseudo-instrucoes sao permitidas.
# =========================================================================

        .data
board:      .byte 0,0,0, 0,0,0, 0,0,0, 0,0,0,0,0,0,0   # 9 celulas + 7 de folga
buf:        .space 8
# Tabela das 8 linhas vencedoras (3 indices cada): linhas, colunas, diagonais
wins:       .byte 0,1,2,  3,4,5,  6,7,8,  0,3,6,  1,4,7,  2,5,8,  0,4,8,  2,4,6

msg_welcome:.asciz "=== Jogo da Velha ===\n"
msg_turnX:  .asciz "Vez de X. Jogada (ex: A1): "
msg_turnO:  .asciz "Vez de O. Jogada (ex: A1): "
msg_inval:  .asciz "Jogada invalida! Tente outra.\n"
msg_winX:   .asciz "X venceu!\n"
msg_winO:   .asciz "O venceu!\n"
msg_draw:   .asciz "Deu velha (empate)!\n"
colhdr:     .asciz "  1 2 3\n"

        .text
        .globl main
main:
        la   a0, msg_welcome
        li   a7, 4
        ecall
        li   s0, 1                 # s0 = jogador atual (1=X, 2=O)
        li   s1, 0                 # s1 = numero de jogadas feitas

loop:
        jal  ra, print_board

        # ---- mensagem do jogador da vez ----
        li   t0, 1
        beq  s0, t0, pr_x
        la   a0, msg_turnO
        j    pr_go
pr_x:
        la   a0, msg_turnX
pr_go:
        li   a7, 4
        ecall

        # ---- le a jogada como texto (ex: "A1") ----
        la   a0, buf
        li   a1, 8
        li   a7, 8
        ecall

        # ---- interpreta a jogada (linha e coluna) ----
        la   t0, buf
        lb   t1, 0(t0)             # caractere da linha
        lb   t2, 1(t0)             # caractere da coluna
        addi t1, t1, -65           # linha
        addi t2, t2, -48           # coluna

        # ---- valida a faixa (0..2) ----
        bltz t1, invalid
        li   t3, 2
        bgt  t1, t3, invalid
        bltz t2, invalid
        bgt  t2, t3, invalid

        # ---- calcula o indice da celula no tabuleiro ----
        slli t3, t1, 1
        add  t3, t3, t2

        # ---- a celula ja esta ocupada? ----
        la   t4, board
        add  t4, t4, t3
        lb   t5, 0(t4)
        bnez t5, invalid

        # ---- coloca a marca do jogador ----
        sb   s0, 0(t4)
        addi s1, s1, 1

        # ---- o jogador atual venceu? ----
        jal  ra, check_win         # a0 = 1 se venceu
        bnez a0, won

        # ---- empate (9 jogadas)? ----
        li   t0, 9
        beq  s1, t0, draw

        # ---- passa a vez para o outro jogador ----
        li   t6, 3
        sub  t6, t6, s0
        j    loop

invalid:
        la   a0, msg_inval
        li   a7, 4
        ecall
        j    loop

won:
        jal  ra, print_board
        li   t0, 1
        beq  s0, t0, win_x
        la   a0, msg_winO
        j    win_go
win_x:
        la   a0, msg_winX
win_go:
        li   a7, 4
        ecall
        j    exit

draw:
        jal  ra, print_board
        la   a0, msg_draw
        li   a7, 4
        ecall

exit:
        li   a7, 10
        ecall

# -------------------------------------------------------------------------
# print_board: imprime o cabecalho de colunas e as 3 linhas (A, B, C).
#   Celula: 0 -> '.', 1 -> 'X', 2 -> 'O'. Nao altera s0/s1.
# -------------------------------------------------------------------------
print_board:
        la   a0, colhdr
        li   a7, 4
        ecall
        li   t0, 0                 # r = 0
pb_row:
        li   t1, 3
        bge  t0, t1, pb_done
        li   t2, 65                # 'A'
        add  t2, t2, t0            # rotulo da linha
        mv   a0, t2
        li   a7, 11
        ecall
        li   a0, 32                # espaco
        li   a7, 11
        ecall
        li   t1, 0                 # c = 0
pb_col:
        li   t3, 3
        bge  t1, t3, pb_eol
        slli t4, t0, 1             # r*2
        add  t4, t4, t0            # r*3
        add  t4, t4, t1            # + c
        la   t5, board
        add  t5, t5, t4
        lb   t6, 0(t5)             # celula
        beqz t6, pb_empty
        li   t2, 1
        beq  t6, t2, pb_um         # celula == 1 ?
        li   a0, 88                # simbolo para celula == 2
        j    pb_putc
pb_um:
        li   a0, 79                # simbolo para celula == 1
        j    pb_putc
pb_empty:
        li   a0, 46                # '.'
pb_putc:
        li   a7, 11
        ecall
        li   a0, 32                # espaco
        li   a7, 11
        ecall
        addi t1, t1, 1
        j    pb_col
pb_eol:
        li   a0, 10                # nova linha
        li   a7, 11
        ecall
        addi t0, t0, 1
        j    pb_row
pb_done:
        jr   ra

# -------------------------------------------------------------------------
# check_win: a0 = 1 se o jogador s0 tem 3 em linha; senao a0 = 0.
#   Percorre as linhas da tabela 'wins'.
# -------------------------------------------------------------------------
check_win:
        la   t0, wins              # ponteiro para a tabela
        li   t1, 0                 # contador de linhas
        li   t2, 7                 # quantas linhas verificar
cw_loop:
        bge  t1, t2, cw_no
        lb   t3, 0(t0)             # i0
        lb   t4, 1(t0)             # i1
        lb   t5, 2(t0)             # i2
        la   t6, board
        add  a1, t6, t3
        lb   a1, 0(a1)             # board[i0]
        add  a2, t6, t4
        lb   a2, 0(a2)             # board[i1]
        add  a3, t6, t5
        lb   a3, 0(a3)             # board[i2]
        bne  a1, s0, cw_next
        bne  a2, s0, cw_next
        bne  a3, s0, cw_next
        li   a0, 1
        jr   ra
cw_next:
        addi t0, t0, 3             # proxima linha (3 bytes)
        addi t1, t1, 1
        j    cw_loop
cw_no:
        li   a0, 0
        jr   ra
