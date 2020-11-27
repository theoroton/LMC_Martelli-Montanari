:- op(20,xfy,?=).

% Pr�dicats d'affichage fournis

% set_echo: ce pr�dicat active l'affichage par le pr�dicat echo
set_echo :- assert(echo_on).

% clr_echo: ce pr�dicat inhibe l'affichage par le pr�dicat echo
clr_echo :- retractall(echo_on).

% echo(T): si le flag echo_on est positionn�, echo(T) affiche le terme T
%          sinon, echo(T) r�ussit simplement en ne faisant rien.

echo(T) :- echo_on, !, write(T).
echo(_).

% Pr�dicat split, r�cup�re le premier et deuxi�me argument d'une
% �quation E.
split(E, G, D) :-
    arg(1, E, G),
    arg(2, E, D).

%R�gle rename : renvoie true si G et D sont des variables.
regle(E, rename) :-
    split(E, G, D),
    var(D),
    var(G), !.

%R�gle simplify : renvoie true si G est une variable et D une constante.
regle(E, simplify) :-
    split(E, G, D),
    var(G),
    not(var(D)),
    not(compound(D)), !.

% R�gle expand : renvoie true si G est une varible, D un terme compos�
% et que G n'est pas dans D.
regle(E, expand) :-
    split(E, G, D),
    var(G),
    compound(D),
    not(occur_check(G, D)), !.

%R�gle check : renvoie true si G et D sont diff�rent et si G est dans D.
regle(E, check) :-
    split(E, G, D),
    G \== D,
    occur_check(G, D), !.

% R�gle orient : renvoie true si G n'est pas une variable et si D en est
% une.
regle(E, orient) :-
    split(E, G, D),
    not(var(G)),
    var(D), !.

% R�gle clash 1 : renvoie true si G et D sont des termes compos�s et
% qu'ils n'ont pas le m�me nombre d'arguments.
regle(E, clash) :-
    split(E, G, D),
    compound(G),
    compound(D),
    functor(G, _, ArityG),
    functor(D, _, ArityD),
    ArityG \== ArityD, !.

% R�gle clash 1 : renvoie true si G et D sont des termes compos�s et
% qu'ils n'ont pas le m�me nom.
regle(E, clash) :-
    split(E, G, D),
    compound(G),
    compound(D),
    functor(G, NameG, _),
    functor(D, NameD, _),
    NameG \== NameD, !.

% R�gle decompose : renvoie true si G et D sont des termes compos�s et
% si ils ont le m�me nombre d'arguments et le m�me nom.
regle(E, decompose) :-
    split(E, G, D),
    compound(G),
    compound(D),
    functor(G, NameG, ArityG),
    functor(D, NameD, ArityD),
    NameG == NameD,
    ArityG == ArityD, !.

%Pr�dicat occur_check 1 : test si V est dans T.
occur_check(V,T) :-
	var(V),
	compound(T),
	functor(T,_,NbP),
	occur_check_comp(V,T,NbP).

%Pr�dicat occur_check 2 : test si V est �gal � T.
occur_check(V,T) :-
	var(V),
	var(T),
	V==T.

% Pr�dicat occur_check_comp 1 : regarde si V est dans le premier
% argument de T.
occur_check_comp(V,T,1) :-
	arg(1,T,Arg),!,
	occur_check(V,Arg).

% Pr�dicat occur_check_comp 2 : pr�dicat r�cursif, regarde pour chaque
% argument de T si V est dedans.
occur_check_comp(V,T,NbP) :-
	arg(NbP,T,Value),
	occur_check(V,Value);
	NbP2 is (NbP-1),
	occur_check_comp(V,T,NbP2).
