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
    substitution_terme_args(Sub, X, T, NbP, Rs).

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