1. **Introduction:**

Ce projet consiste à faire la réalisation d’un commutateur réseau Ethernet à quatre voies, à base de cartes FPGA.

Un réseau Ethernet se base sur le transfert d'une trame comportant huit champs dont le nombre d'octets varie entre 27 et 91 octets. Le nombre total d'octets de la trame dépend de la taille du champ données qui varie entre 0 et 64 octets.

Un commutateur réseau réalise plusieurs fonctions différentes, dans le cadre de ce projet nous avons réalisé certaines de ces fonctions: Le canal de transmission Tx, Le canal de réception Rx, le générateur CRC, le circuit d'aiguillage, le codeur/décodeur Manchester et le détecteur de préambule.   

Dans ce document, nous allons présenter le travail que nous avons fait pour la réalisation et la description VHDL du circuit CRC-32, du circuit d'aiguillage, ainsi que du canal Tx. 

1. **Circuit CRC-32:**

Ce circuit à pour fonction de vérifier que le transfère a été fait correctement, il permet de calculer un code binaire sur 32 bits à partir des octets du champ 3 (adresse source) jusqu'au champ 6 (données) de la trame qu'il reçoit, et ce par rapport à un polynôme générateur prédéfini.  

Le polynôme générateur que nous avons utilisé est le suivant:

G32x=x32+x26+x23+x22+x16+x12+x11+x10+x8+x5+x4+x2+1

Son code hexadécimal correspondant est x"104C11D35". 

**Figure  SEQ Figure \\* ARABIC 1. Circuit CRC-32**

**Figure  SEQ Figure \\* ARABIC 1. Circuit CRC-32**.



L'entité permettant de décrire ce circuit en VHDL et de le simuler sur QUARTUS est représenté par le schéma (circuit CRC et banc d'essai) de la figure 2:



**Figure  SEQ Figure \\* ARABIC 2. Banc d'essai du CRC-32**

**Figure  SEQ Figure \\* ARABIC 2. Banc d'essai du CRC-32**![CircuitCRC32\_BM.jpg](rapport\_final.004.jpeg)

Le circuit CRC comporte 4 entrées: D\_in pour recevoir la donnée en commençant par le LSB, H, reset, Enable qui, si elle est à l'état haut, le circuit fonctionne, sinon, les sorties des bascules sont figées, et l'entrée RAZ (remise à zéro). Le bloc comporte une sortie: r\_out, un vecteur de 32 bits qui permet d'afficher les sorties des bascules soit le code CRC-32.

Le banc d'essai comporte un registre à décalage de 624 bits, afin de recueillir les 78 octets de la trame, il est commander par le signal d'horloge H, un reset r un signal 'dec' permettant le décalage à droite du registre et par conséquent d'injecter les bits de la donnée dans le circuit CRC en commençant par le LSB,  et un signal 'load' permettant de le charger par les octets de la trame préalablement stockés dans la constante FRAME.

L'entité globale (banc d'essai + CRC-32) ne comporte que les  entrée load, h, r et stcrc qui reliée à de cet enable permet d'autoriser la conversion, et la sortie r sur 32 bits.

- Résultats de la simulation:

Afin de tester et simuler notre description, nous avons chargé la constante FRAME par la donnée de 18 octets suivante **x" 4142 4344 4546 4748 58AA 1518 1314 1712 1419"**, et avons maintenu le signal 'stcrc' à l'état haut durant 144 périodes d'horloge. Nous avons obtenu le résultat de la figure 3. 

**Figure  SEQ Figure \\* ARABIC 3. Résultat de la simulation du générateur CRC**

**Figure  SEQ Figure \\* ARABIC 3. Résultat de la simulation du générateur CRC**![BM\_CodeurCRC32.JPG](rapport\_final.006.jpeg)

![frame\_crc.JPG](rapport\_final.007.jpeg)Afin de vérifier le résultat de la simulation, nous avons utilisé un générateur en ligne permettant de préciser le polynôme générateur. Comme ce calculateur en ligne injecte les bits par le MSB, il nous a fallu inverser la donnée dans notre constante FRAME en considérant le bit de gauche comme étant le LSB:

**Figure  SEQ Figure \\* ARABIC 4. Calcul du CRC-32 par un générateur rn ligne**

**Figure  SEQ Figure \\* ARABIC 4. Calcul du CRC-32 par un générateur rn ligne**![CRC\_online.JPG](rapport\_final.009.jpeg)Nous avons obtenu les mêmes résultats comme le montre la figure 4.





1. **Circuit d'aiguillage:**

L'une des fonctions les plus importantes d'un commutateur, c'est la fonction d'aiguillage, elle permet d'acheminer une trame reçue du port émetteur, vers le port destinataire, selon les adresses précisées dans les octets 1,2,…,12 de la trame.

Il nous est demandé de réaliser et de décrire une forme simple du circuit d'aiguillage sans organe de commande représenté par la figure 5. 

L'aiguilleur comporte:

- Signal d'horloge et reset;
- 4 entrées: P1, P2, P3 et P4, de 1 bit chacune permettant de recevoir les bits données;
- 4 sorties : ToP1, ToP2, ToP3 et ToP4, qui reçoivent  les bits des entrées Pi;
- 4 entrées de sélection : sel1, sel2, sel3 et sel4, de 2 bits  et dont chacune correspond à l'une des entrées Pi et qui permet selon sa valeur d'acheminer cette entrée vers les différentes sorties ToP;
- Une sortie d'erreur qui se met à 1 si deux entrées souhaitent envoyer à une même sortie, autrement dit si au moins deux entrées sel sont égales.

Le tableau suivant résume les sorties vers lesquelles la donnée reçue sur l'un des ports Pi va être acheminée en fonction des valeurs de son entrée de sélection SELi.




|SELi|00|01|10|11|
| :-: | :-: | :-: | :-: | :-: |
|Sortie vers laquelle Pi va être acheminéé|ToP1|ToP2|ToP3|ToP4|

**Figure  SEQ Figure \\* ARABIC 5. Schéma du circuit d'aiguillage**

**Figure  SEQ Figure \\* ARABIC 5. Schéma du circuit d'aiguillage**![aiguilleur.JPG](rapport\_final.011.jpeg)

L'entité permettant de décrire ce circuit en VHDL et de le simuler sur QUARTUS est représentée par le schéma (banc d'essai) de la figure 6:

- Les registres Reg\_in1, Reg\_in2, Reg\_in3 et Reg\_in4, sont des registres à décalage de 16 bits (nous avons choisi une donnée de deux octets pour la simulation mais nous pouvons très bien augmenter la taille), ils seront chargés par la donnée à diriger vers les registres reg\_out en activant l'entrée Load. 

**Figure  SEQ Figure \\* ARABIC 6. Banc d'essai du circuit d'aiguillage**

**Figure  SEQ Figure \\* ARABIC 6. Banc d'essai du circuit d'aiguillage**![banc\_aiguilleur.JPG](rapport\_final.013.jpeg)Les sorties du circuit sont à 16 bits ils permettent d'afficher les valeurs reçues sur les ToPi.

- Résultats de la simulation:

Afin de simuler notre circuit d'aiguillage, nous avons utilisé les données suivantes:

reg\_in1 = x"0123";  
reg\_in2 = x"4567";
reg\_in3 = x"89AB";
reg\_in4 = x"CDEF";

Nous avons activé les signaux de sélection comme suit:

` `SEL1 = 2;
SEL2 = 3;
SEL3 = 1;
SEL4 = 0;

Les résultats attendus sont donc comme suit:

reg\_out1 = x"CDEF";  
reg\_out2 = x"89AB";
reg\_out3 = x"0123";
reg\_out4 = x"4567";

Après simulation, nous avons obtenu les mêmes résultats. La figure 7 montre les résultats de la simulation.

Nous remarquons aussi que dans le cas où les signaux de sélection sont égaux, le signal d'erreur est activé.

**Figure  SEQ Figure \\* ARABIC 7. résultats de la simulation du circuit d'aiguillage**

**Figure  SEQ Figure \\* ARABIC 7. résultats de la simulation du circuit d'aiguillage**

1. **Canal Rx:**

Ce circuit permet de recevoir la trame bit par bit codée en Manchester, de la convertir en binaire puis de la stocker dans une fifo sous forme de paquets d'octets.

**Figure  SEQ Figure \\* ARABIC 8. Circuit "data\_path" du canal Rx**

**Figure  SEQ Figure \\* ARABIC 8. Circuit "data\_path" du canal Rx**![img131.jpg](rapport\_final.017.jpeg)La figure 8 présente le circuit récepteur (data\_path).


- Reg\_in: Ce registre comporte 1456 bits et permet de contenir la trame reçue.
- Dec1: permet de décaler reg\_in;
- Eof indique la fin de la trame;
- Sof indique le début de la trame.
- Détecteur de préambule: permet de détecter les octets de préambule:
- La sortie MATCH se met à 1 à chaque fois qu'un octet de préambule est détecté;
- La sortie SFD se met à 1 lorsque le neuvième octet de préambule est détecté, elle indique le début de la trame;
- L'entrée de 1 bit permet d'injecter les bits du préambule dans le détecteur.
- Reg16: ce registre à décalage a une taille de 16 bits, il permet de contenir les octets de la trame codé en Manchester, il est ensuite injecté dans le décodeur Manchester.
- Dec2: permet de décaler reg16;
- Démultiplexeur: permet de sélectionner le bloc dans lequel les bits de reg\_in vont être injectés:
- Sel = 1 => détecteur de préambule;
- Sel = 2 => reg16.
- C16: compteur 5 bits permet de compter les bits injectés dans reg16;
- Inc: entrée qui permet d'incrémenter le compteur;
- RAZ: remise à zéro du compteur;
- C16equF: sortie mise à quad C16 = 15.
- Fifo 8x128: permet de contenir les octets de la trame après décodage Manchester;
- Séquenceur: permet le contrôle du Datapath de manière séquentielle. 

Afin de contrôler le circuit data\_path nous utilisons un séquenceur dont l'algorithme numérique est représenté par la figure 9.

Cet algorithme est ensuite traduit en tableau binaire représenté par le tableau suivant

|Entrées|Etat présent|Etat suivant|Sorties|R|
| :-: | :-: | :-: | :-: | :-: |
||000      0|001      1|Raz|R1|
|Not (sof)|001      1|001      1|Dec1|R2|
|sof|001      1|010      2|Dec1, enable|R3|
|Not (sfd)|010      2|010      2|Dec1, enable|R4|
|Sfd|010      2|011      3||R5|
||011      3|100      4|Inc|R6|
||100      4|101      5|Dec1, dec2|R7|
|Not (C16equF)|101      5|011      3||R8|
|C16equF|101      5|110      6||R9|
|Full|110      6|110      6||R10|
|Not (full)|110      6|111      7|wr|R11|
|Eof|111      7|000      0||R12|
|Not (eof)|111      7|011      3|Raz, dec1, dec2|R13|

**Figure  SEQ Figure \\* ARABIC 9. Algorithme numérique du séquenceur du canal Rx**

**Figure  SEQ Figure \\* ARABIC 9. Algorithme numérique du séquenceur du canal Rx**![img132.jpg](rapport\_final.019.jpeg) 

Après avoir décri ce tableau en VHDL, nous avons simulé son fonctionnement tout en affichant une sortie indiquant les états afin de vérifier le déroulement du séquenceur.

Nous avons ensuite testé notre circuit en utilisant un banc d'essai contenant:

- ` `l'entité data\_generator, utilisée dans le banc d'essai du canal Tx;
- L'entité canal\_Tx qui permet de transmettre la donnée au récepteur en série
- L'entité canal\_Rx qui reçoit la tramz du canal\_Tx et qui la stocke dans la fifo 8x128.

Nous rappelons que la trame générée par data\_generator est la suivante:

` `**(x"00", x"00", x"00", x"00",x"00",x"01",	-- adresse source**

**x"00", x"00", x"00", x"00",x"00",x"02", 	-- adresse dest**

**x"00", x"01", 					-- taille données**

**x"ff",							-- données**

**x"A6", x"01", x"7E", x"9E" );			-- CRC 32**

Nous avons fait la simulation avec une fréquence de 50Mhz, pour un "end\_time" de 120µs temps suffisant pour que l'émission et la réception soient faites au niveau de Tx et de Rx.

A la fin de la simulation, nous avons activé le signal "read" de la fifo afin de visualiser sur sa sortie les octets qu'elle contient.

Nous avons obtenu les résultats présentés par la figure 10.

![rx.JPG](rapport\_final.020.jpeg)Nous remarquons que les octets stockés dans la fifo correspondent aux données qui ont été transmises par data\_generator, le circuit est donc fonctionnel.

**Figure  SEQ Figure \\* ARABIC 10. Résultats de la simulation du canal Rx**

**Figure  SEQ Figure \\* ARABIC 10. Résultats de la simulation du canal Rx**














1. **Canal Tx:**

Ce circuit permet d'émettre la trame bit par bit codée en Manchester. La trame est initialement placée dans une pile FIFO par l'élément central, elle est lue par le circuit d'émission, codée en Manchester puis transmise en série sur la ligne Tx.  

La figure 11 présente le circuit (datapath) du canal Tx.

Ce circuit est contrôlé par le séquenceur dont l'algorithme numérique est représenté par la figure 12.

L'algorithme est ensuite traduit en tableau binaire représenté par le tableau 3. 

![tx.JPG](rapport\_final.022.jpeg)

**Figure  SEQ Figure \\* ARABIC 11. Circuit canal Tx**

**Figure  SEQ Figure \\* ARABIC 11. Circuit canal Tx**











**Figure  SEQ Figure \\* ARABIC 12. Algorithme numérique du séquenceur Tx**

**Figure  SEQ Figure \\* ARABIC 12. Algorithme numérique du séquenceur Tx**![organigramme\_erp - Page 2.png](rapport\_final.025.png)![organigramme\_erp - Page 1.png](rapport\_final.026.png)![organigramme\_erp - Page 3.png](rapport\_final.027.png)



|Entrées|<p>Etat présent</p><p>E3 E2 E1 E0</p>|<p>Etat suivant</p><p>E3 E2 E1 E0</p>|Sorties|R|
| :-: | :-: | :-: | :-: | :-: |
||0|1|RAZ2, RAZ3, RAZ4|1|
|EMPTY = 1|1|1||2|
|EMPTY = 0|1|2|INIT\_PR|3|
||2|3|SEL0, DEC\_REGOUT, DEC\_PR, INC2|4|
|C2EQU144 = 0|3|2||5|
|C2EQU144 = 1|3|4||6|
||4|5|RAZ2, RD|7|
||5|6|LD1, INC3|8|
||6|7|DEC1, SEL1, DEC\_REGOUT, INC2|9|
|C2EQUF = 0|7|6||10|
|C2EQUF = 1|7|8||11|
|C3EQU13 = 1|8|9|LD2|12|
|C3EQU13 = 0|8|10||13|
|EMPTY = 0|9|4||14|
|EMPTY = 1|9|9||15|
|C3EQU14 = 1|10|11|LD3|16|
||11|9|LD4|17|
|C3EQU14 = 0|10|12||18|
|C3EQUREG4 = 1|12|13||19|
|C3EQUREG4 = 0|12|9||20|
|SOF = 0|13|13|DEC\_REGOUT, SEL2|21|
|SOF = 1|13|14|DEC\_REGOUT, SEL2|22|
|EOF = 1|14|0||23|
|EOF = 0|14|14|DEC\_REGOUT|24|

` `PAGE   \\* MERGEFORMAT 14

