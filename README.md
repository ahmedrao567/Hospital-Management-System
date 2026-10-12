# Hospital Management System

A full-stack Hospital Management System built using Java Spring Boot Microservices and React.

## Tech Stack

### Backend
- Java 21
- Spring Boot
- Spring Security
- Spring Cloud Gateway
- Eureka Server
- Spring Data JPA
- MySQL
- Maven

### Frontend
- React
- Vite
- Mantine UI
- Axios
- React Router

## Microservices

- Eureka Server
- API Gateway
- User Service
- Profile Service
- Appointment Service
- Pharmacy Service
- Media Service

## Project Status

🚧 Currently under development.

## Docker Compose

The root `.env` sets `COMPOSE_PARALLEL_LIMIT=1` so the initial image build runs serially. This helps avoid Docker Desktop daemon crashes or `EOF` errors when multiple Maven and frontend builds run at the same time on limited-memory machines.