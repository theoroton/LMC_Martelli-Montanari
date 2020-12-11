%Pr�dicats d'affichage
echo(T) :- echo_on, !, write(T).
echo(_).
echoNL(T) :- echo(T), nl.
echoSEP() :- nl, echoNL("====================="), nl.

/*
 * Pr�dicat pour lancer tous les tests de tous les pr�dicats.
 * Si on arrive � FIN, les tests sont valides.
 */
lancerTests() :-
    set_echo,
    echoNL("DEBUT DES TESTS :"),

    echoSEP(),
    lancerTest_Regle,
    echoSEP(),
    lancerTest_Occur_Check,
    echoSEP(),
    lancerTest_Reduit,
    echoSEP(),
    lancerTest_Unifie,
    echoSEP(),

    echoNL("FIN DES TESTS").
