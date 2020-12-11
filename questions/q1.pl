% D�finition de l'op�rateur "?=".
:- op(20,xfy,?=).

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
% Pr�dicat unifie(P) :
% R�sout le syst�me d'�quation P.

/*
 * Si le syst�me P est vide, on a r�ussi � unfier (Prolog se
 * charge d'�crire le mgu).
 * P : syst�me vide.
 */
unifie([]) :- nl, !.

/*
 * Si le syst�me P est �gal � bottom, alors on ne peut pas l'unifier.
 * P : bottom.
 */
unifie(bottom) :- nl, fail, !.

/*
 * Trouve la r�gle pouvant �tre appliqu� � E (t�te du syst�me P) et
 * applique cette r�gle � E. Reduit prend le reste L (reste du syst�me
 * P) et transforme ce syst�me en syst�me Q. Appelle ensuite unifie sur
 * le nouveau syst�me Q.
 * P : syst�me � unifier.
 */
unifie([E|L]) :-
    regle(E, R),
    reduit(R, E, L, Q),
    unifie(Q).
