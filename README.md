# README: Projet d'Analyse de Données pour la Prédiction de Catégories de Véhicules

## Description du Projet

Ce projet consiste en l'analyse de données d'une concession automobile dans le but de prédire la catégorie de véhicules la plus adaptée à ses clients. Le projet est divisé en trois étapes principales : l'identification des catégories de véhicules, la construction d'un modèle de prédiction, et l'application du modèle aux nouveaux clients.
#### le video de la démonstration https://youtu.be/v9uxGicwtbA

## Prérequis

#### RStudio: Nécessaire pour exécuter les scripts R.

#### Python: Pour exécuter les scripts de nettoyage de données.

## Bibliothèques R Requises

dplyr

caret

rpart

C50

tree

e1071

RJDBC

rJava

DBI

## Fichiers de Données

#### Fichiers Excel: client_12.xlsx et Immatriculation.xlsx.

#### Scripts Python: Pour le nettoyage des données.

## Etapes du Projet

### 1. Identification des Catégories de Véhicules

Fusionner les données Clients et Immatriculations pour obtenir une matrice client-véhicule.
Effectuer un clustering (K-means) pour identifier des clusters de clients et de véhicules.
Associer chaque cluster à une catégorie de véhicules et introduire une nouvelle variable "Catégorie" dans la matrice fusionnée.

### 2. Construction d'un Modèle de Prédiction

Intégrer la variable "Catégorie" dans la matrice Clients.
Séparer cette matrice en ensembles d'apprentissage et de test.
Entraîner des classifieurs (rpart(), C50(), tree, etc.) sur l'ensemble d'apprentissage.
Évaluer et sélectionner le classifieur le plus performant sur l'ensemble de test.

### 3. Application du Modèle aux Nouveaux Clients
Appliquer le classifieur sélectionné aux données Marketing.

Générer les prédictions de catégories de véhicules pour chaque nouveau client.

## Problèmes Rencontrés et Solutions

Volume de Données Élevé: Le fichier d'immatriculation contenant 2 millions de lignes a nécessité un ordinateur puissant pour l'entraînement des modèles, qui a duré environ 7 heures.

## Conclusion

Ce projet illustre l'utilisation efficace de techniques d'analyse de données pour fournir des insights commerciaux précieux. L'approche adoptée permet de prédire de manière fiable la catégorie de véhicules adaptée à chaque client, en utilisant des méthodes avancées de machine learning et d'analyse de données
