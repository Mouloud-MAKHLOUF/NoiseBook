--une requête qui porte sur au moins trois tables ;
    --ensemble des utilisateur qui ont dans leur playlist un nombre cumulé de morceaux differents et superieur à 10

SELECT DISTINCT utilisateur.id_utilisateur 
FROM utilisateur,playlist, relation_playlist_morceau
WHERE utilisateur.id_utilisateur = playlist.id_utilisateur
AND playlist.id_playlist = relation_playlist_morceau.id_playlist
GROUP BY utilisateur.id_utilisateur
HAVING COUNT(DISTINCT relation_playlist_morceau.id_morceau)>10;

--ne ’auto jointure’ ou ’jointure réflexive’ (jointure de deux copies d’une même table)
    --ensemble des utilisateurs qui sont abonnés entre eux A abonné à B et B abonné à A
SELECT R1.utilisateur1, R1.utilisateur2
FROM relation_follow AS R1 ,relation_follow AS R2
WHERE R1.utilisateur1 = R2.utilisateur2
AND R2.utilisateur1 = R1.utilisateur2;

--une sous-requête corrélée ;
    --Tout les groues qui particeperont à des concerts futur et qui ont deja des avis
SELECT groupe.nom_grp
FROM groupe
WHERE EXISTS (
  SELECT *
  FROM relation_groupe_concert_futur
  WHERE relation_groupe_concert_futur.id_groupe = groupe.id_groupe
    AND EXISTS (
      SELECT *
      FROM avis_groupe
      WHERE avis_groupe.id_groupe = groupe.id_groupe
    )
);
--une sous-requête dans le FROM 
    --Renvoie le nombre de concerts futur qu'animera chaque groupe

SELECT t1.id_groupe, t1.nom_grp, t2.nb_concerts
FROM (
  SELECT id_groupe, nom_grp
  FROM groupe
) AS t1
JOIN (
  SELECT id_groupe, COUNT(*) AS nb_concerts
  FROM relation_groupe_concert_futur
  GROUP BY id_groupe
) AS t2 ON t1.id_groupe = t2.id_groupe;

--une sous-requête dans le WHERE ;
--Toutes les personnes qui n'ont jamais participer a un concert et qui n'ont jamais poster d'avis

SELECT p.id_utilisateur ,p.nom
FROM personne p 
WHERE p.id_personne NOT IN
(
    SELECT relation_personne_participe.id_personne
    FROM relation_personne_participe
) 
AND p.id_personne NOT IN
(
    SELECT p2.id_personne
    FROM  personne p2, utilisateur u, avis a
    WHERE  p2.id_utilisateur= u.id_utilisateur 
    AND a.id_utilisateur = u.id_utilisateur

);

--deux agrégats nécessitant GROUP BY et HAVING 
    --List de lieu qui ont abrité ou abriteront plus de 4 concerts
SELECT l.id_lieu ,l.nom_lieu  ,COUNT(*) AS nb_concerts
FROM lieu l, concert_passe p, concert_futur f
WHERE l.id_lieu = p.lieu AND l.id_lieu = f.lieu
GROUP BY l.id_lieu
HAVING COUNT(*)>4;

--Une requête impliquant le calcul de deux agrégats 
    -- Le lieu qui a acceuile les concerts dont la moyenne des prix est la plus élevé
WITH moyenne_lieu AS(
    SELECT l.id_lieu ,AVG(p.prix) AS prix_moyen
    FROM lieu l, concert_passe p
    WHERE l.id_lieu = p.lieu
    GROUP BY l.id_lieu
)

SELECT ml.id_lieu, prix_moyen
FROM moyenne_lieu ml 
WHERE prix_moyen = (
    SELECT MAX(prix_moyen)
    FROM moyenne_lieu
);
--une jointure externe (LEFT JOIN, RIGHT JOIN ou FULL JOIN) ;
    -- Donner tout les groupes de musique 
    --avec les lieu dans lesquel ils ont 
    --joué en inculant ceux qui n'ont pas encore jouer sur scence
SELECT p.id_groupe, p.nom_grp
FROM groupe p LEFT JOIN relation_groupe_concert_passe gcp 
ON p.id_groupe = gcp.id_groupe 
LEFT JOIN concert_passe cp ON gcp.id_concert= cp.id_concert
LEFT JOIN lieu l ON l.id_lieu = cp.lieu;
--deux requêtes équivalentes exprimant une condition de totalité, l’une avec des sous requêtes 
--corré-lées et l’autre avec de l’agrégation 
    --Avec correlation 
    -- Personne qui ont assistés à tout les concerts du groupe x
/*SELECT p.id, p.nom
FROM  personne p
WHERE p.id NOT IN 
    (
        SELECT p.id, p.nom
        FROM  personne p, 
        WHERE p.id NOT IN 
    )*/
--obtenir les dix groupes dont les concerts ont eu le plus de succès chaque mois en termes de nombre d'utilisateurs ayant indiqué souhaiter y participer
---------------------------------------------
WITH classement_groupes AS (
 SELECT
   g.id_groupe,
   EXTRACT(MONTH FROM cf.date_concert) AS mois,
   COUNT(DISTINCT rpp.id_personne) AS nombre_participants,
   ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM cf.date_concert), EXTRACT(MONTH FROM cf.date_concert) ORDER BY COUNT(DISTINCT rpp.id_personne) DESC) AS rn
 FROM
   concert_futur cf
 JOIN
   relation_groupe_concert_futur rgcf ON cf.id_concert = rgcf.id_concert
 JOIN
   groupe g ON rgcf.id_groupe = g.id_groupe
 LEFT JOIN
   relation_personne_interesse rpi ON cf.id_concert = rpi.id_concert
 LEFT JOIN
   relation_personne_participe rpp ON cf.id_concert = rpp.id_concert
 LEFT JOIN
   personne p ON rpi.id_personne = p.id_personne OR rpp.id_personne = p.id_personne
 LEFT JOIN
   relation_appartenance ra ON p.id_personne = ra.id_personne AND rgcf.id_groupe = ra.id_groupe
 LEFT JOIN
   relation_utilisateur_concert_futur rucf ON cf.id_concert = rucf.id_concert
 LEFT JOIN
   utilisateur u ON p.id_utilisateur = u.id_utilisateur OR rucf.id_utilisateur = u.id_utilisateur
 GROUP BY
   g.id_groupe,
   EXTRACT(YEAR FROM cf.date_concert),
   EXTRACT(MONTH FROM cf.date_concert)
)
SELECT
 cg.mois,
 g.nom_grp,
 cg.nombre_participants
FROM
 classement_groupes cg
JOIN
 groupe g ON cg.id_groupe = g.id_groupe
WHERE
 cg.rn <= 10
ORDER BY
 cg.mois,
 cg.rn;
 --Cette requête récursive récupérera la liste complète des concerts futurs pour le groupe avec l'ID 5, triés par ordre chronologique.
WITH RECURSIVE concert_sequence AS (
 SELECT
   cf.id_concert,
   cf.date_concert,
   ROW_NUMBER() OVER (ORDER BY cf.date_concert) AS rn
 FROM
   concert_futur cf
 JOIN
   groupe g ON cf.id_concert = g.id_groupe
 WHERE
   g.id_groupe = 5 -- Replace <ID_DU_GROUPE> with the desired group ID
   AND cf.date_concert >= CURRENT_DATE -- Only future concerts
), concert_list AS (
 SELECT
   id_concert,
   date_concert,
   rn
 FROM
   concert_sequence
 WHERE
   rn = 1
 UNION ALL
 SELECT
   cs.id_concert,
   cs.date_concert,
   cl.rn + 1
 FROM
   concert_sequence cs
 JOIN
   concert_list cl ON cs.rn = cl.rn + 1
)
SELECT
 id_concert,
 date_concert
FROM
 concert_list
ORDER BY
 rn;
--Requete sur les conditions de totalité
SELECT DISTINCT
 p.id_personne,
 p.nom,
 p.prenom
FROM
 personne p
WHERE
 NOT EXISTS (
   SELECT 1
   FROM
     utilisateur u
   WHERE
     u.id_utilisateur = p.id_utilisateur
 )
;
------
SELECT
 p.id_personne,
 p.nom,
 p.prenom
FROM
 personne p
LEFT JOIN
 utilisateur u ON p.id_utilisateur = u.id_utilisateur
GROUP BY
 p.id_personne,
 p.nom,
 p.prenom
HAVING
 COUNT(u.id_utilisateur) = 0


