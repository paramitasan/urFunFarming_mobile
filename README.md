# urfunfarming_mobile

**Urban Farming Community and Local Harvest Marketplace**

Platform-Based Programming (PBP) Final Group Project (Theme: Sustainable Living)<br>
Faculty of Computer Science, Universitas Indonesia, Odd Semester 2026/2027



## Project Links

| Resource | Link |
| --- | --- |
| Repository | https://github.com/paramitasan/urFunFarming_mobile/ |
| Deployed app (PWS) | https://paramita-santoso-urfunfarming.pws.cs.ui.ac.id/ |
| External API | [BMKG public weather forecast API](https://data.bmkg.go.id/prakiraan-cuaca/) |
| Figma design | https://www.figma.com/design/rDovEM0bwhNE0xkgKZhwV4/Farmerzz?node-id=0-1&t=uf8tBdtybxcNt5PB-1 |
| APK | (soon) |



## About the App

urFunFarming connects small urban growers with each other and with people nearby who want locally grown food. A resident who grows vegetables or herbs on a balcony, rooftop, small garden or hydroponic setup can:

- record their gardens and the plants in them,
- keep a dated journal of how each plant is growing,
- ask and answer growing questions in a community forum,
- post surplus harvest in a marketplace so buyers nearby can arrange pickup,
- check the weather before planning a pickup or plant care task.



## Group Members and Modules

| Full name | NPM | Assigned module |
| --- | --- | --- |
| Angin Putih Ranulaksmi Tsurayya Hapsoro | 2506557936 | 3 |
| Azkal Azkiya Arifi Putra | 2506636991 | 2 |
| Marcel Mikula | 2606816592 | 4 |
| Muhamad Idris Kamal | 2506637073 | 1 |
| Paramita Santoso | 2506554171 | 6 |
| Tahir Ahmad | 2606816466 | 5 |

Module names: 1. Landing Page, Authentication and User Profiles; 2. Gardens and Plantings; 3. Plant Progress Journal; 4. Harvest Marketplace; 5. Care Planning and Weather; 6. Community Questions and Answers (Forum).



## User Roles

| Role | What they can do |
| --- | --- |
| Visitor (not logged in) | See the landing page, browse marketplace listings, explore public gardens and read forum question titles. Contact details, full forum discussions and private records are hidden. |
| Grower | Everything a buyer can do, plus manage their own gardens and plantings, write plant journal entries, set each plant journal public or private, and post harvest listings. |
| Buyer | See growers' contact details on listings, read public gardens and public plant journals, and ask, answer and vote in the forum. |
| Administrator | Manage users and moderate all records through the Django admin. |

One account can be both a grower and a buyer (`accounts.Profile` has `is_grower` and `is_buyer`). Being logged in never lets a user edit someone else's records: every edit and delete view checks the owner, and private records are filtered out in the query itself, not only hidden in the template.



## App Navigation

Every module has its own page. Pages are reached from two floating bottom bars and from the tiles on the Home page.

| Module | Where in the app | Code |
| --- | --- | --- |
| 1. Authentication and Profiles | Avatar (top right) → Profile | `lib/auth/` |
| 2. Gardens and Plantings | Grower tools bar → My gardens; Main bar → Explore (public gardens); Home tiles | `lib/gardens/`, `lib/explore/` |
| 3. Plant Progress Journal | Grower tools bar → Plant journal; Home tile | `lib/journal/` |
| 4. Harvest Marketplace | Main bar → Market; Home tile | `lib/marketplace/` |
| 5. Care Planning and Weather | Grower tools bar → Plant care; Home tile | `lib/care/` |
| 6. Community Q&A Forum | Main bar → Forum; Home tile | `lib/forum/` |

The main bar (Home, Market, Forum, Explore) is shown to everyone. Growers also get a grower tools bar above it (My gardens, Plant journal, Plant care).



## Web Service & Data Integration (Flutter ↔ PWS Django REST Framework)

`urfunfarming_mobile` communicates with the existing **urFunFarming** web application deployed on **PWS (Pacil Web Service)** through a RESTful JSON API built with **Django REST Framework (DRF)**. Both the web and mobile clients share the same backend database so user accounts, gardens, plant journals, plant care tasks, marketplace listings, and forum threads stay synchronized in real time.


### Architecture & Request Flow

1. **Client Layer (Flutter / Dart):** Mobile screens send asynchronous HTTP requests (`http` package) to the PWS HTTPS endpoints and parse the JSON responses into Dart model classes (`fromJson`).
2. **API & Serialization Layer (Django REST Framework):** Incoming requests are routed to DRF `APIView` / `ViewSet` endpoints on PWS. DRF **Serializers** validate incoming data, enforce field-level constraints, and convert Django ORM querysets into JSON responses.
3. **Authentication & Authorization:**
   - Users log in or register through the `/api/auth/` endpoints.
   - Login returns a token. The app keeps it and sends `Authorization: Token <token>` with every later request.
   - If the server answers 401 (the token expired), the app drops the token and retries the request once as a visitor.
   - Role flags (`is_grower` and `is_buyer` on `accounts.Profile`) are returned upon login so the Flutter UI dynamically enables or restricts grower/buyer actions, while DRF permission classes enforce object-level ownership on the server.
4. **External Weather Integration:** Care planning and pickup scheduling features retrieve forecast data from the [BMKG public weather forecast API](https://data.bmkg.go.id/prakiraan-cuaca/), either directly or normalized through the Django backend.


### Core API Endpoints Overview

| Module | Endpoint Prefix | Supported Operations |
| --- | --- | --- |
| Auth & Profiles | `/api/auth/`, `/api/profiles/` | Register, login, logout, fetch/update user profile and role flags |
| Gardens & Plantings | `/api/gardens/`, `/api/plantings/` | List public/owned gardens, create/edit/delete gardens and plantings |
| Plant Progress Journal | `/api/journals/` | View public entries, create/edit/delete dated growth logs and visibility |
| Harvest Marketplace | `/api/marketplace/` | Browse available listings, create/manage harvest posts, view grower contact |
| Care Planning & Weather | `/api/care-tasks/`, `/api/weather/` | CRUD plant care schedules and fetch BMKG weather forecasts |
| Community Q&A Forum | `/api/forum/` | List questions, post questions/answers, upvote/downvote discussions |



## Per Module

### Module 1: Landing Page, Authentication and User Profiles (Idris)

- **Scope:** Mobile onboarding/landing screen, login and registration flows integrated with PWS authentication, and user profile management.


### Module 2: Gardens and Plantings (Azkal)

- **Scope:** Browse public urban gardens, manage personal garden spaces (balcony, rooftop, hydroponic), and track active plantings.


### Module 3: Plant Progress Journal (Ranu)

- **Scope:** Chronological growth logs per planting with public/private visibility controls.


### Module 4: Harvest Marketplace (Marcel)

- [Marcel Mikula · 2606816592: scope, mobile screens, Django API and local demo](docs/marketplace.md). Open it from the **Market** tab in the bottom bar.


### Module 5: Care Planning and Weather (Tahir)

- **Scope:** Plant care task reminders paired with local weather forecasts from the BMKG API.


### Module 6: Community Questions and Answers (Paramita)

- **Scope:** Community Q&A feed where buyers and growers can post questions, submit answers, and vote on helpful responses.



## How to Run

You need Flutter 3.50 or newer.

```bash
flutter pub get
flutter run
```

The app uses the PWS site by default (set in `lib/config.dart`). To use another backend, for example Django on your own machine (`10.0.2.2` is how the Android emulator reaches your computer):

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

To try the app in Chrome, use `tool/demo_marketplace.sh` instead of `flutter run -d chrome`. It starts the Django API and serves the app at http://127.0.0.1:8000/app/.

Run the tests with `flutter test`.



## Packages

- `http`: calls the Django REST API.
- `flutter_svg`: draws the icons exported from our Figma design.
- `material_ui`: Flutter's Material library, a separate package from Flutter 3.50 on.



## AI Assistance
Google Gemini assisted with drafting README.md. Claude assisted with the app skeleton and with editing README.md.