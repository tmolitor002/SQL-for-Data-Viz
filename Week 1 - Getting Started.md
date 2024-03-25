# Introduction

This training will utilize SQLite and DB Browser to build and understanding of how to utilize SQL for Data Visualization resources. This course assumes you have no prior knowledge of SQL, but does assume you have a level of comfort with exploring and learning. If you already are comfortable with another tech stack or would like to use a different set of tools to learn SQL, you'll be responsible for both the setup and bridging any differences with this training.


# Contents

- Required Software
- Suggested Software
- Sample Project Overview
- Sample Data Review
# Required Software

## [SQLite](https://www.sqlite.org/index.html)

SQLite is the most used database engine in the world, built into most computers and mobile phones. It is small, quick, and self-contained, works across all common operating systems, and it's source code is free to use of any purpose.

For this training, the SQLite database will be hosted locally on your machine, meaning you won't have to sign up or configure any cloud environments.

### Install SQLite

While SQLite can be installed by itself, we will install SQLite as part of the the install for DB Browser. To install SQLite on its own, you can start by downloading the latest version [here](https://www.sqlite.org/index.html).

### Additional Information

SQLite does not natively support some common features found in paid database engines such as using schemas or creating views. See [[Advanced SQL Theory|Advanced Theory]] for more information.

It is possible SQLite will not be used as the database engine used by clients. Many opt for paid cloud services such as Azure, Snowflake, AWS, Databricks, Oracle, and [many more](https://db-engines.com/en/ranking/relational+dbms). There are also plenty of other open source systems such as MySQL, PostgreSQL, and MongoDB. Each database may have it's own "flavor" of SQL, meaning a function used in one system is not a function in another. The scope of this training will cover the commonly used functions to get you up and running to start building dashboards.

## [DB Browser for SQLite](https://sqlitebrowser.org/dl/)

DB Browser is an open source interface that can be used to interact with SQLite databases. It can be used to import/export data, query tables, and create new tables or delete existing ones. Similar to SQLite, it is possible you'll be using a different interface that is designed to work with your database engine. Some common interfaces include SSMS (Microsoft SQL Server Management Studio) and [dbt](https://www.getdbt.com).

### Install DB Browser for SQLite

Start by navigating to the DB Browser [download page](https://sqlitebrowser.org/dl/) and selecting the correct version of DB Browser for your operating system. For Windows users, it is recommended to use the standard installer version.

### Additional Information

DB Browser has many features that may not be available in other database tools, or would be restricted from use by the access credentials used by a dashboard developer.

# Suggested Software

None of the below tools are required for this course, but may be helpful to have in your back pocket as you begin to create your very own SQL statements.

## [Notepad++](https://notepad-plus-plus.org/)

Notepad++ is a popular text editor that supports several languages, including SQL. Define the language used through either the language menu or by saving a file as a recognized type for automatic code highlighting.

## [Draw.io](https://www.drawio.com/) (web)

Draw.io is a great tool for creating functional diagrams. We will use it to summarize the relationships between different tables.

## [GitHub](https://github.com/) (web)

GitHub is a popular repository used for version control and sharing code with others. A copy of this course is available on GitHub [here](https://github.com/tmolitor002/SQL-for-Data-Viz). 
