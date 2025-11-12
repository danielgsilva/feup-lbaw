# AskIT (Collaborative Q&A)

Creating a space where developers can quickly find accurate, reliable answers to their coding questions. What sets it apart is the community-driven approach, where users contribute their expertise, and the platform's voting and reputation system rewards quality contributions. We hope to create a self-sustaining cycle of knowledge.  

This proposal corresponds to an information system with a web interface to manage a community of collaborative questions and answers. Any registered user can submit questions or answers. The questions and answers can be voted on by the rest of the community. It is also possible to associate brief comments to the questions or the answers. Each user has an associated score that is calculated considering the votes on its questions and answers.

## Project Components
| Component | Grade |
|-|-|
| [ER: Requirements Specification](https://gitlab.up.pt/lbaw/lbaw2425/lbaw24141/-/wikis/ER) | 18.6/20 |
| [EBD : Database Specification](https://gitlab.up.pt/lbaw/lbaw2425/lbaw24141/-/wikis/EBD) | 15.6/20 | 
| [EAP : Architecture Specification and Prototype](https://gitlab.up.pt/lbaw/lbaw2425/lbaw24141/-/wikis/EAP) | 16.4/20 |
| [PA : Product and Presentation](https://gitlab.up.pt/lbaw/lbaw2425/lbaw24141/-/wikis/PA) | 18.2/20 |

## Technologies

The practical work is based on a fixed technology stack. Key technologies used are:

* `GitLab` for collaborative software development, documentation, and versioning
* `PostgreSQL` as the database
* `PHP` as the programming language on the server
* `Docker` as the virtualization environment
* `Laravel` as the server web framework
* `NGINX` as the web server
* `HTML, CSS and JavaScript` as client languages
* `Bootstrap` for responsive design and UI components

## Testing our image locally

You can run our image locally to test it:

```bash
docker run -d --name lbaw24141 -p 8001:80 gitlab.up.pt:5050/lbaw/lbaw2425/lbaw24141
```

## Usage

### Administration Credentials


| Email | Password |
|----------|----------|
| admin@example.com | 1234 |

### User Credentials

| Type | email | Password |
|------|----------|----------|
| basic account with some notifications | alice.santos@example.com | 1234 |
| banned user | pedro.oliveira@example.com  | 1234 |


### Mailtrap Credentials

| Email | Password |
|----------|----------|
| lbaw2024g1@gmail.com | lbaw2024t14g1 |

Maybe, need to log in to Google, because we signed up with Google in mailtrap website.

With that, can also try log in with google feature.

## Demo

https://github.com/user-attachments/assets/b79a0bfa-47be-4ca0-9514-67254568ae14


# Team
* Diogo Salazar Ramos
* Rafael Filipe Barbosa da Costa
* Daniel Gomes Silva
* Tiago Miguel Alves Pires