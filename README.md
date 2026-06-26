# Relatório de Correção – Jogo da Velha em RISC-V
Aluno: Juliano Machado da Silva


Foram corrigidos os cinco erros que impediam o funcionamento correto do jogo.

Erro 1 – Troca de jogador:  
Após cada jogada válida, o próximo jogador era calculado corretamente, mas esse valor não era armazenado. Assim, o mesmo jogador continuava jogando.

Adicionei a instrução:  
mv s0, t6

Que atualiza o registrador que indica quem é o jogador da vez.

Erro 2 – Conversão da coluna

O programa convertia o valor da coluna usando o código ASCII do caractere  0. Isso fazia com que a entrada fosse interpretada de forma errada. Como a entrada válida é de 1 a 3, a conversão deveria ser feita a partir do caractere 1.

Alterei a instrução:  
addi t2, t2, -48

Para:  
addi t2, t2, -49


Assim, as entradas 1, 2 e 3 foram convertidas corretamente para 0, 1 e 2.

Erro 3 – Cálculo da posição no tabuleiro:  
O cálculo da posição da jogada usava apenas linha × 2 + coluna. O correto era linha × 3 + coluna. Isso resultava em algumas jogadas sendo gravadas em posições erradas do tabuleiro.

Adicionei a instrução:  
add t3, t3, t1

com isso, o cálculo final passou a ser equivalente a linha × 3 + coluna.

Erro 4 – Impressão das peças:  
Os caracteres mostrados no tabuleiro estavam invertidos. O valor correspondente ao jogador X aparecia como O, e vice-versa.

Erro 5 – Verificação de vitória:  
O programa checava apenas sete combinações vencedoras, ignorando uma possibilidade. Isso fazia com que algumas vitórias não fossem reconhecidas.

Alterei o valor do contador de verificações de:  
li t2, 7

para:  
li t2, 8

isso permitiu que todas as oito combinações de vitória fossem verificadas.


Conclusão:
Após corrigir os cinco erros, o jogo passou a funcionar corretamente. As jogadas são exibidas no tabuleiro, os jogadores alternam suas jogadas e o programa identifica corretamente as situações de vitória.