# Automotive-Market-Analysis-with-Neo4j

## Introduction
This project focuses on analyzing the automotive market by creating a graph database using Neo4j. The data, initially sourced from Kaggle in tabular format, is transformed and loaded into Neo4j to enable advanced querying and insights into automotive industry trends and relationships.

## Project Overview
The project involves several key components:

- Data Extraction and Cleaning: Data was obtained from Kaggle and cleaned to ensure accuracy and consistency.
- Database Creation: The cleaned data is loaded into a Neo4j graph database for querying and analysis.
- Analysis and Visualization: The project includes queries and visualizations to extract meaningful insights from the data.

## Data Processing
1. Data Source: The data was sourced from Kaggle in tabular format, containing various attributes related to the automotive market.

2. Data Cleaning: Prior to loading the data into Neo4j, it was cleaned to handle missing values, correct inconsistencies, and normalize the data for better integration.

3. Data Transformation: The cleaned data was transformed into a format suitable for graph representation.

## Neo4j Database
- Data Preparation: Scripts were used to prepare the data for import into Neo4j.

- Data Loading: Data was loaded into Neo4j using Cypher queries. This involves creating nodes, relationships, and properties that represent the automotive market.

- Query Examples: Examples of Cypher queries are provided to demonstrate how to extract insights and analyze relationships within the graph database.

## Documentation
A comprehensive PDF document is included in this repository:

### Presentation.pdf:
  - Content: The PDF includes answers to key questions about the project's scope, data formalization in NoSQL databases, and a comparison of MongoDB, Cassandra, and Neo4j.
  - Rationale: The document explains why Neo4j was chosen over other NoSQL databases and provides references to papers supporting the choice.
  - Practical Examples: Includes practical examples of how to query the Neo4j database for various use cases and describes the entire database creation process.

## Authors
- [Martin Martuccio](https://github.com/Martin-Martuccio) - Project Author
- [Samuele Pellegrini](https://github.com/PSamK) - Project Author

Report : [Report Link](Report.pdf)

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
