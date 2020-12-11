% D�finition de l'op�rateur "?=".
:- op(20,xfy,?=).

% Pr�dicats d'affichage fournis

% set_echo: ce pr�dicat active l'affichage par le pr�dicat echo.
set_echo :- assert(echo_on).

% clr_echo: ce pr�dicat inhibe l'affichage par le pr�dicat echo.
clr_echo :- retractall(echo_on).

% echo(T): si le flag echo_on est positionn�, echo(T) affiche le terme T
%          sinon, echo(T) r�ussit simplement en ne faisant rien.
echo(T) :- echo_on, !, write(T).
echo(_).

/*
 * Pr�dicat echoNL : permet d'afficher le terme T est de faire
 * un retour � la ligne.
 * T : terme � afficher.
 */
echoNL(T) :- echo(T), nl.

/*
 * Pr�dicat split : permet de couper une �quation E en 2 et de r�cup�rer
 * la partie gauche G et la partie droite D.
 * E : �quation � couper.
 * G : partie gauche de l'�quation.
 * D : partie droite de l'�quation.
 */
split(E, G, D) :-
    arg(1, E, G),
    arg(2, E, D).


% ------------------------------------------------------------------------
% Pr�dicat regle(E, R) :
% D�termine la r�gle de transformation R qui s'applique � l'�quation E.

/*
 * R�gle clean : renvoie true si X et T sont �gaux.
 * E : �quation donn�e.
 * R : r�gle clean.
 */
regle(E, clean) :-
    split(E, X, T),
    X == T, !.

/*
 * R�gle rename : renvoie true si X et T sont des variables.
 * E : �quation donn�e.
 * R : r�gle rename.
 */
regle(E, rename) :-
    split(E, X, T),
    var(X),
    var(T),
    X \== T, !.

/*
 * R�gle simplify : renvoie true si X est une variable et T une
 * constante.
 * E : �quation donn�e.
 * R : r�gle simplify.
 */
regle(E, simplify) :-
    split(E, X, T),
    var(X),
    atom(T), !.

/*
 * R�gle expand : renvoie true si X est une variable, T un terme
 * compos� et si X n'est pas dans T.
 * E : �quation donn�e.
 * R : r�gle expand.
 */
regle(E, expand) :-
    split(E, X, T),
    var(X),
    compound(T),
    not(occur_check(X, T)), !.

/*
 * R�gle check : renvoie true si X et T sont diff�rents et si X est dans
 * T.
 * E : �quation donn�e.
 * R : r�gle check.
 */
regle(E, check) :-
    split(E, X, T),
    X \== T,
    occur_check(X, T), !.

/*
 * R�gle orient : renvoie true si T n'est pas une variable et si X en
 * est une.
 * E : �quation donn�e.
 * R : r�gle orient.
 */
regle(E, orient) :-
    split(E, T, X),
    not(var(T)),
    var(X), !.

/*
 * R�gle decompose : renvoie true si X et T sont des termes compos�s et
 * s'ils ont le m�me nombre d'arguments et le m�me nom.
 * E : �quation donn�e.
 * R : r�gle decompose.
 */
regle(E, decompose) :-
    split(E, Fg, Fd),
    compound(Fg),
    compound(Fd),
    functor(Fg, NameG, ArityG),
    functor(Fd, NameD, ArityD),
    NameG == NameD,
    ArityG == ArityD, !.

/*
 * R�gle clash : renvoie true si X et T sont des termes compos�s et
 * s'ils n'ont pas le m�me nombre d'arguments.
 * E : �quation donn�e.
 * R : r�gle clash.
 */
regle(E, clash) :-
    split(E, Fg, Fd),
    compound(Fg),
    compound(Fd),
    functor(Fg, _, ArityG),
    functor(Fd, _, ArityD),
    ArityG \== ArityD, !.

/*
 * R�gle clash : renvoie true si X et T sont des termes compos�s et
 * s'ils n'ont pas le m�me nom.
 * E : �quation donn�e.
 * R : r�gle clash.
 */
regle(E, clash) :-
    split(E, Fg, Fd),
    compound(Fg),
    compound(Fd),
    functor(Fg, NameG, _),
    functor(Fd, NameD, _),
    NameG \== NameD, !.

/*
 * R�gle fail : renvoie true si aucune autre r�gle n'a pu �tre
 * appliqu�e.
 * R : r�gle fail.
 */
regle(_, fail) :- !.


% ------------------------------------------------------------------------
% Pr�dicat occur_check(V, T) :
% Teste si la variable V appara�t dans le terme T.

/*
 * Test si V est dans T si T est un terme compos�. (on
 * v�rifie dans tous les arguments de T si V s'y trouve).
 * V : variable � trouv� dans T.
 * T : terme � v�rifier.
 */
occur_check(V, T) :-
	var(V),
	compound(T),
	functor(T, _, NbArgs),
	occur_check_args(V, T, NbArgs).

/*
 * Test si V et T sont des variables et sont �gales.
 * V : variable � trouv� dans T.
 * T : variable � v�rifier.
 */
occur_check(V, T) :-
	var(V),
	var(T),
	V == T.


% Pr�dicat occur_check_args(V, T, N) :
% Teste si la variable V appara�t dans un argument du terme T.

/*
 * Test si V est dans le premier argument de T.
 * V : variable � trouv� dans T.
 * T : terme � v�rifier.
 * N : indice du premier argument
 */
occur_check_args(V, T, 1) :-
	arg(1, T, Arg), !,
	occur_check(V, Arg).

% Pr�dicat occur_check_args: regarde si V est dans un des arguments
% de T (NbArgs : nombre d'arguments de T).
/*
 * Test si V est dans un des arguments de T. (on v�rifie dans
 * tous les arguments de T si V s'y trouve).
 * V : variable � trouv� dans T.
 * T : terme � v�rifier.
 * N : nombre d'arguments et v�rifier.
 */
occur_check_args(V, T, NbArgs) :-
	arg(NbArgs, T, Arg),
	occur_check(V, Arg);
	NbArgs2 is (NbArgs - 1),
	occur_check_args(V, T, NbArgs2).


% ------------------------------------------------------------------------
% Pr�dicat reduit(R, E, P, Q) :
% Transforme le syst�me d'�quations P en le syst�me d'�quations Q par
% application de la r�gle de transformation R � l'�quation E.

/*
 * Retourne le syst�me P sans l'�quation E.
 * R : r�gle clean.
 * P : reste des �quations de P.
 * Q : syst�me P sans l'�quation E apr�s application de la r�gle R.
 */
reduit(clean, _, P, P) :- !.

/*
 * Substitue X part T, et renvoie le syst�me P sans l'�quation trait�e
 * (X et T sont des variables).
 * R : r�gle rename.
 * E : premi�re �quation de P.
 * P : reste des �quations de P.
 * Q : syst�me P sans l'�quation E apr�s application de la r�gle R.
 */
reduit(rename, E, P, P) :-
    split(E, X, T),
    X = T, !.

/*
 * Substitue X par T, et renvoie le syst�me P sans l'�quation trait�e
 * (X est une variable, T est une constante).
 * R : r�gle simplify.
 * E : premi�re �quation de P.
 * P : reste des �quations de P.
 * Q : syst�me P sans l'�quation E apr�s application de la r�gle R.
 */
reduit(simplify, E, P, P) :-
    split(E, X, T),
    X = T, !.

/*
 * Substitue X par T, et renvoie le syst�me P sans l'�quation trait�e
 * (X est une variable, T est un terme compos�).
 * R : r�gle expand.
 * E : premi�re �quation de P.
 * P : reste des �quations de P.
 * Q : syst�me P sans l'�quation E apr�s application de la r�gle R.
 */
reduit(expand, E, P, P) :-
    split(E, X, T),
    X = T, !.

/*
 * Retourne bottom si la r�gle check est appliqu�e.
 * R : r�gle check.
 * Q : bottom.
 */
reduit(check, _, _, bottom) :- !.

/*
 * Inverse T et X et ajoute l'�quation invers�e dans le syst�me Q en
 * lui concat�nant le syst�me P.
 * R : r�gle orient.
 * E : �quation � invers�e.
 * P : reste des �quations de P.
 * Q : syst�me P avec l'�quation E invers�e apr�s application de la
 * r�gle R.
 */
reduit(orient, E, P, [X ?= T|P]) :-
    split(E, T, X), !.

/*
 * D�compose les 2 termes compos�s de E dans une liste Decomp et
 * unifie cette liste avec le syst�me P.
 * R : r�gle decompose.
 * E : �quation � d�compos�e.
 * P : reste des �quations de P.
 * Q : syst�me P avec les �quations d�compos�es apr�s application
 * de la r�gle R.
 */
reduit(decompose, E, P, Q) :-
    decompose_liste(E, Decomp),
    union_systemes(Decomp, P, Q), !.

/*
 * Retourne bottom si la r�gle clash est appliqu�e.
 * R : r�gle clash.
 * Q : bottom.
 */
reduit(clash, _, _, bottom) :- !.

/*
 * Retourne bottom si la r�gle fail est appliqu�e.
 * R : r�gle fail.
 * Q : bottom.
 */
reduit(fail, _, _, bottom) :- !.


% ------------------------------------------------------------------------
% Pr�dicat decompose_liste(E, Decomp) :
% D�compose une �quation E de la forme f(s1,...,sn) = f(t1,...,tn) en
% une liste Decomp de forme [s1 ?= t1, ...., sn ?= tn].

/*
 * D�compose l'�quation E en 2 dans la liste Decomp. Fg est le terme
 * compos� de gauche et Fd celui de droite.
 * E : �quations � d�compos�e.
 * Decomp : liste des �quations d�compos�es.
 */
decompose_liste(E, Decomp) :-
    split(E, Fg, Fd),
    functor(Fg, _, NbArgs),
    decompose_liste_args(Fg, Fd, NbArgs, [], Decomp).


% Pr�dicat decompose_liste_args(Fg, Fd, N, Le, Ls) :
% Prend le Ni�me argument de chaque terme compos�e Fg et Fd, cr�e
% l'�quation En (Xn ?= Tn), l'ajoute dans la liste de sortie Ls
% et concat�ne cette liste avec la liste d'entr�e Le.

/*
 * D�compose le premier argument de Fg et Fd, cr�e l'�quation E1
 * (X1 ?= T1), l'ajoute dans Ls et concat�ne Le.
 * Fg : terme compos� de gauche.
 * Fd : terme compos� de droite.
 * N : indice du premier argument.
 * Le : liste des �quations d�j� d�compos�es.
 * Lr : liste des �quations d�compos�es � laquelle on ajoute E1.
 */
decompose_liste_args(Fg, Fd, 1, Le, [X1 ?= T1|Le]) :-
    arg(1, Fg, X1),
    arg(1, Fd, T1), !.

/*
 * D�compose le Ni�me argument de Fg et Fdn cr�e l'�quation En
 * (Xn ?= Tn), l'ajoute dans Le et appelle r�cursivement ce
 * pr�dicat avec le (N-1)i�me terme.
 * Fg : terme compos� de gauche.
 * Fd : terme compos� de droite.
 * N : indice du Ni�me argument.
 * Le : liste des �quations d�j� d�compos�es.
 * Lr : liste des �quations d�compos�s � laquelle on ajoute En.
 */
decompose_liste_args(Fg, Fd, N, Le, Lr) :-
    arg(N, Fg, XN),
    arg(N, Fd, TN),
    N2 is (N-1),
    decompose_liste_args(Fg, Fd, N2, [XN ?= TN|Le], Lr).


% ------------------------------------------------------------------------
% Pr�dicat union_systems(S1, S2, Q) :
% Unifie les syst�mes S1 et S2 en syst�me Q.

/*
 * Si S1 est vide, alors on renvoie le syst�me S2.
 * S1 : syst�me vide.
 * S2 : second syst�me.
 * Q : syst�me S2 � renvoyer.
 */
union_systemes([], S2, S2).

/*
 * Ajoute X (t�te de S1) en t�te du syst�me Q et unifie L (reste de
 * S1) avec le syst�me S2.
 * S1 : premier syst�me.
 * S2 : second syst�me.
 * Q : syst�me unifi� � renvoyer.
 */
union_systemes([X|L], S2,[X|Q]) :- union_systemes(L, S2, Q).


% ------------------------------------------------------------------------
% Pr�dicat choix_strategie(S, P, Q, E, R) :
% Choisis la strat�gie � utiliser en fonction de S. Transforme le
% syst�me P en syst�me Q et indique l'�quation E � traiter ainsi que la
% r�gle R � appliquer sur cette �quation.

/*
 * Choix de la strat�gie o� l'on s�lectionne la premi�re �quation
 * du syst�me P.
 * S : choix premier.
 * P : syst�me d'�quations.
 * Q : syst�me d'�quations transform�e.
 * E : �quation � trait�e.
 * R : r�gle � appliquer � E.
 */
choix_strategie(choix_premier, P, Q, E, R) :-
    choix_premier(P, Q, E, R), !.

/*
 * Choix de la strat�gie o� l'on s�lectionne l'�quation de plus
 * grand poids du syst�me P.
 * S : choix pondere.
 * P : syst�me d'�quations.
 * Q : syst�me d'�quations transform�e.
 * E : �quation � trait�e.
 * R : r�gle � appliquer � E.
 */
choix_strategie(choix_pondere, P, Q, E, R) :-
    choix_pondere(P, Q, E, R), !.

/*
 * Choix de la strat�gie o� l'on s�lectionne la derni�re �quation
 * du syst�me P.
 * S : choix dernier.
 * P : syst�me d'�quations.
 * Q : syst�me d'�quations transform�e.
 * E : �quation � trait�e.
 * R: r�gle � appliquer � E.
 */
choix_strategie(choix_dernier, P, Q, E, R) :-
    choix_dernier(P, Q, E, R), !.


% ------------------------------------------------------------------------
% Pr�dicat choix(P, Q, E ,R) :
% Trouve l'�quation E � traiter ainsi que la r�gle R � appliquer � cette
% �quation. Transforme le syst�me P en syst�me Q en enlevant l'�quation
% E � traiter.

/*
 * Choix de l'�quation avec la strat�gie premier. S�lectionne la
 * r�gle pouvant �tre appliqu�e � la premi�re �quation.
 * P : syst�me d'�quations (X t�te du syst�me et L reste du syst�me).
 * Q : syst�me d'�quations transform�e.
 * E : �quation � traiter.
 * R : r�gle � appliquer � E.
 */
choix_premier([E|L], L, E, R) :-
    regle(E, R), !.

/*
 * Choix de l'�quation avec la strat�gie pondere. S�lectionne la
 * premi�re �quation � laquelle on peut appliquer la r�gle de plus
 * grand poids. Transforme ensuite le syst�me P en syst�me Q en
 * enlevant l'�quation E trouv�e.
 * P : syst�me d'�quations.
 * Q : syst�me d'�quations transform�e.
 * E : �quation � traiter.
 * R : r�gle � appliquer � E.
 */
choix_pondere(P, Q, E, R) :-
    equation_a_traitee(P, E, R),
    transformer_systeme(P, E, Q), !.

/*
 * Choix de l'�quation avec la strat�gie dernier. S�lectionne la
 * r�gle pouvant �tre appliqu�e � la derni�re �quation.
 * P : syst�me d'�quations.
 * Q : syst�me d'�quations transform�e.
 * E : �quation � traiter.
 * R : r�gle � appliquer � E.
 */
choix_dernier(P, L, E, R) :-
    reverse(P, [E|L]),
    regle(E, R), !.


% ------------------------------------------------------------------------
% Pr�dicat poids(R, P) :
% Donne le poids P associ� � une r�gle R.
poids(expand, 0).
poids(decompose, 1).
poids(orient, 2).
poids(clean, 3).
poids(rename, 3).
poids(simplify, 3).
poids(fail, 4).
poids(clash, 4).
poids(check, 4).


% ------------------------------------------------------------------------
% Pr�dicat equation_a_traitee(P, E, R) :
% Trouve l'�quation E � traiter d'un syst�me P avec la r�gle R � lui
% appliquer dans le choix pondere.

/*
 * S'il n'y a plus qu'une �quation dans P, on la renvoie ainsi
 * que la r�gle qui peut lui �tre appliqu�e.
 * P : syst�me d'une �quation.
 * E : �quation � traiter.
 * R : r�gle � utiliser sur l'�quation E.
 */
equation_a_traitee([E], E, R) :-
    regle(E, R), !.

/*
 * Compare une �quation N et une �quation N+1 et d�termine laquelle
 * des 2 est plus prioritaire en fonction du poids de la r�gle qui
 * lui est associ�e. Recommence l'op�ration avec l'�quation choisie
 * et le reste des �quations de P.
 * P : syst�me d'�quations (E1 Ni�me �quation, E2 (N+1)i�me �quation,
 * L reste des �quations).
 * E : �quation � traiter.
 * R : r�gle � utiliser sur l'�quation E.
 */
equation_a_traitee([E1,E2|L], E, R) :-
    regle(E1, R1),
    regle(E2, R2),
    poids(R1, P1),
    poids(R2, P2),
    (  P1 >= P2
    -> equation_a_traitee([E1|L], E, R), !
    ;  equation_a_traitee([E2|L], E, R), !
     ).


% ------------------------------------------------------------------------
% Pr�dicat transformer_systeme(P, E, Q) :
% Trouve l'�quation E du syst�me P, la retire de P et indique le
% r�sultat dans Q.

/*
 * Si le syst�me est vide, on renvoit un syst�me vide.
 * P : syst�me vide.
 * Q : syst�me vide.
 */
transformer_systeme([], _, []) :- !.

/*
 * Si l'�quation en t�te de P est �gal � l'�quation E, on retourne le
 * reste de P concat�n� � toutes les �quations pr�c�dant E dans P. Sinon
 * on relance le pr�dicat avec le reste des �quations de P.
 * P : syst�me d'�quations (X premi�re �quation de P, L reste des
 * �quations de P).
 * E : �quation � trouver.
 * Q : syst�me d'�quations sans l'�quation E.
 */
transformer_systeme([X|L], E, Q) :-
    (   X == E
    ->  Q = L, !
    ;   transformer_systeme(L, E, L2),
        Q = [E|L2]).


% ------------------------------------------------------------------------
% Pr�dicat unifie(P, S) :
% R�sout le syst�me d'�quation P avec la strat�gie S.

/*
 * Si le syst�me P est vide, on a r�ussi � unifier (Prolog se
 * charge d'�crire le mgu).
 * P : syst�me vide.
 */
unifie([], _) :- nl, !.

/*
 * Si le syst�me P est �gal � bottom, alors on ne peut pas l'unifier.
 * P : bottom.
 */
unifie(bottom, _) :- nl, fail, !.

/*
 * Trouve l'�quation E � traiter et la r�gle R � lui appliquer en
 * fonction de la strat�gie S. Transforme le syst�me P en syst�me P2,
 * qui contient toutes les �quations de P sans l'�quation E.
 * Applique la r�gle R � l'�quation E et transforme le syst�me P2 en
 * syst�me Q. Appelle ensuite unifie sur le nouveau syst�me Q.
 * P : syst�me d'�quations � unifier.
 * S : strat�gie � utiliser.
 */
unifie(P, S) :-
    choix_strategie(S, P, P2, E, R),
    echo(system: P), echo("\n"),
    echo(R: E), echo("\n"),
    reduit(R, E, P2, Q),
    unifie(Q, S), !.


% ------------------------------------------------------------------------
% Pr�dicat unif(P,S) et trace_unif(P,S) :
% Inhibe ou active la trace d'affichage des r�gles appliqu�es � chaque
% �tape de l'algorithme d'unification.

/*
 * D�sactive l'affichage des r�gles appliqu�es � chaque �tape.
 * P : syst�me d'�quations � unifier.
 * S : strat�gie � utiliser.
 */
unif(P, S) :-
    clr_echo,
    unifie(P, S).

/*
 * Active l'affichage des r�gles appliqu�es � chaque �tape.
 * P : syst�me d'�quations � unifier.
 * S : strat�gie � utiliser.
 */
trace_unif(P, S) :-
    set_echo,
    echo("\n"),
    unifie(P,S).
