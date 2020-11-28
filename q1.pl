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


% ------------------------------------------------------------------------
% Pr�dicat regle :
% D�termine la r�gle R pouvant �tre appliqu� � l'�quation E.

% R�gle rename : renvoie true si G et D sont des variables.
regle(E, rename) :-
    split(E, G, D),
    var(G),
    var(D),
    G \== D, !.

% R�gle simplify : renvoie true si G est une variable et D une
% constante.
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

% R�gle check : renvoie true si G et D sont diff�rent et si G est dans
% D.
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

% R�gle clash : renvoie true si G et D sont des termes compos�s et
% qu'ils n'ont pas le m�me nombre d'arguments.
regle(E, clash) :-
    split(E, G, D),
    compound(G),
    compound(D),
    functor(G, _, ArityG),
    functor(D, _, ArityD),
    ArityG \== ArityD, !.

% R�gle clash : renvoie true si G et D sont des termes compos�s et
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

% R�gle clean : renvoie true si G et D sont des variables et si elles
% sont �gales.
regle(E, clean) :-
    split(E, G, D),
    var(G),
    var(D),
    G == D, !.


% ------------------------------------------------------------------------
% Pr�dicat occur_check :
% Teste si la variable V apparait dans le terme T.

% Pr�dicat occur_check : test si V est dans T.
occur_check(V,T) :-
	var(V),
	compound(T),
	functor(T,_,NbP),
	occur_check_comp(V,T,NbP).

% Pr�dicat occur_check : test si V est �gal � T.
occur_check(V,T) :-
	var(V),
	var(T),
	V==T.

% Pr�dicat occur_check_comp : regarde si V est dans le premier
% argument de T.
occur_check_comp(V,T,1) :-
	arg(1,T,Arg),!,
	occur_check(V,Arg).

% Pr�dicat occur_check_comp : pr�dicat r�cursif, regarde pour chaque
% argument de T si V est dedans.
occur_check_comp(V,T,NbP) :-
	arg(NbP,T,Value),
	occur_check(V,Value);
	NbP2 is (NbP-1),
	occur_check_comp(V,T,NbP2).


% ------------------------------------------------------------------------
% Pr�dicat reduit :
% Transforme le syst�me P en syst�me Q en appliquant la r�gle R �
% l'�quation E.

% Pr�dicat reduit avec la r�gle rename :
% On remplace dans P tous les X par T et on r�cup�re le syst�me apr�s
% substitution dans Q.
% T est une variable.
reduit(rename, E, P, Q) :-
    split(E, X, T),
    substitution(P, X, T, Q), !.

% Pr�dicat reduit avec la r�gle simplify :
% On remplace dans P tous les X par T et on r�cup�re le syst�me apr�s
% substitution dans Q.
% T est une constante.
reduit(simplify, E, P, Q) :-
    split(E, X, T),
    substitution(P, X, T, Q), !.

% Pr�dicat reduit avec la r�gle expand :
% On remplace dans P tous les X par T et on r�cup�re le syst�me apr�s
% substitution dans Q.
% T est un terme compos�.
reduit(expand, E, P, Q) :-
    split(E, X, T),
    substitution(P, X, T, Q), !.

% Pr�dicat reduit avec la r�gle check :
% On retourne bottom dans Q si la r�gle check est appliqu�e.
reduit(check, _, _, Q) :-
    Q = bottom, !.

% Pr�dicat reduit avec la r�gle orient :
% On inverse T et X et on l'ajoute dans le syst�me Q. On
% concat�ne ensuite P � ce syst�me.
reduit(orient, E, P, Q) :-
    split(E, T, X),
    Q = [X ?= T|P], !.

% Pr�dicat reduit avec la r�gle decompose :
% On d�compose les 2 termes de E dans Lr. On unifie ensuite Lr et P dans
% Q.
reduit(decompose, E, P, Q) :-
    decompose_liste(E, Lr),
    union(Lr,P,Q).

% Pr�dicat reduit avec la r�gle clash :
% On retourne bottom dans Q si la r�gle clash est appliqu�e.
reduit(clash, _, _, Q) :-
    Q = bottom, !.

% Pr�dicat reduit avec la r�gle clean :
% On retourne P sans l'�quation trait� pour la r�gle clean.
reduit(clean, _, P, Q) :-
    Q = P, !.


% ------------------------------------------------------------------------
% Pr�dicat substitution :
% Remplace toutes les occurences de X par T dans le syst�me P et renvoie
% un syst�me Q.

% Si le syst�me P est vide, on ne renvoie rien.
substitution([],_,_,[]) :- !.

% Substitue la partie droite Dr de l'�quation Eq, et appelle
% r�cursivement substitution pour substituer la partie restante L du
% syst�me d'�quations.
% A chaque substitution, on ajoute � la liste r�sultat l'�quation "Ga ?=
% DrS", o� Ga est la partie gauche de l'�quation Eq courante et DrS la
% partie droite de l'�quation apr�s substitution, � laquelle on
% concat�ne le reste de la liste r�sultat.
substitution([Eq|L], X, T, [Ga ?= DrS|SubL]) :-
    split(Eq, Ga, Dr),
    substitution_terme(Dr, X, T, DrS),
    substitution(L, X, T, SubL).

% Si la partie � substitu� Sub est diff�rente de X, alors on renvoie
% Sub.
substitution_terme(Sub, X, _, Sub) :-
    not(compound(Sub)),
    Sub \== X, !.

% Si la partie � substitu� Sub est �gal � X, alors on renvoie le terme
% T.
substitution_terme(Sub, X, T, T) :-
    not(compound(Sub)),
    Sub == X, !.

% Si la partie � substitu� Sub est un terme compos�, on va regarder si
% les termes qui la compose contiennent X. Le r�sultat de cette
% substitution se trouvera dans Rs.
substitution_terme(Sub, X, T, Rs) :-
    compound(Sub),
    functor(Sub, _, NbP),
    substitution_arg(Sub, X, T, NbP, Rs).

% On substitue le premier argument de Sub, et on renvoie le r�sultat
% dans Rs.
substitution_terme_args(Sub, X, T, 1, Rs) :-
    arg(1, Sub, Value),
    substitution_terme(Value, X, T, V),
    functor(Sub, N, A),
    functor(Rs, N, A),
    arg(1, Rs, V), !.

% On substitue chacun des arguments de Sub, et on renvoie le r�sultat
% dans Rs.
substitution_terme_args(Sub, X, T, N1, Rs) :-
    arg(N1, Sub, Value),
    substitution_terme(Value, X, T, V),
    functor(Sub, N, A),
    functor(Rs, N, A),
    arg(N1, Rs, V),
    N2 is (N1-1),
    substitution_terme_args(Sub, X, T, N2, Rs).


% ------------------------------------------------------------------------
% Pr�dicat decompose_liste :
% D�compose une �quation de la forme f(s1,...,sn) = f(t1,...,tn) en une
% liste.

% D�compose l'�quation E dans la liste Lr.
decompose_liste(E,Lr) :-
    split(E, Fg, Fd),
    functor(Fg, _, N),
    decompose_liste_arg(Fg, Fd, N, [], Lr).

% D�compose les premiers arguments de chaque fonction et les places dans
% Lr.
decompose_liste_arg(Fg, Fd, 1, Le, Lr) :-
    arg(1, Fg, X1),
    arg(1, Fd, Y1),
    Lr = [X1 ?= Y1|Le], !.

% D�compose tous les arguments de chaque fonction et les places dans Lr.
decompose_liste_arg(Fg, Fd, N, Le, Lr) :-
    arg(N, Fg, XN),
    arg(N, Fd, YN),
    L = [XN ?= YN|Le],
    N2 is (N-1),
    decompose_liste_arg(Fg, Fd, N2, L, Lr).


% ------------------------------------------------------------------------
% Pr�dicat unifie :
% R�sout le syst�me d'�quation P.

% Si on arrive la liste vide, le syst�me P a �tait r�solu.
unifie([]) :- nl, echo('Yes'), !.

% Si on trouve bottom, le syst�me P ne peut pas �tre r�solu.
unifie(bottom) :- nl, echo('No'), !, false.

% Applique la r�gle R � l'�quation E et affiche la r�gle
% utilis�. Appel r�cursif unifie pour le syst�me Q.
unifie([E|P]) :-
    regle(E, R),
    echo(system: [E|P]), nl,
    echo(R: E), nl,
    reduit(R, E, P, Q),
    unifie(Q).


