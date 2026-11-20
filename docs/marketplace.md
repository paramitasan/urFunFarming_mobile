# Harvest Marketplace — mobile scope and API

Module 4 · Marcel Mikula · urFunFarming, PBP 2026/27

**Goal.** In Depok and nearby cities, a grower can list surplus vegetables, fruit or herbs for sale or free collection. A neighbour can find the offer and arrange pickup directly. A successful demo goes from a real Django listing to its mobile detail, from a member sign-in to shared contact details, and from a grower edit back to the same updated database record.

| User | In scope | Boundary |
| --- | --- | --- |
| Visitor | Browse, search, filter, open offers; check forecast pickup windows | No grower email/phone; no writes |
| Signed-in buyer or grower | See the grower's shared contact fields on a visible detail | Payment, messages and collection arrangements happen outside the app |
| Grower | Post a listing with produce, stock, price basis and collection dates | Only the actual signed-in grower is set as owner |
| Owner | Use “My listings”; edit, pause, resume or delete own offers | Paused/expired items stay private; being another grower grants no management access |

**Mobile flow:** Explore → search/filter → harvest details → sign in for contact or check pickup weather. A grower can instead take Post a harvest → save → My listings → Edit/Pause/Delete. The date window follows Jakarta local time. The forecast is supplied by BMKG for the collection city, not a private address. There is no reservation, stock deduction, delivery, cart or in-app checkout. An empty catalogue, missing contacts, an expired token, an invalid form and a weather outage are handled explicitly.

### How the parts fit

Module owner: Marcel Mikula, NPM 2606816592. The home page opens the existing Marketplace module with a single MarketplaceButton. Opening it fetches data from Django; it does not keep a separate stock database. The button can accept a MarketApi from the future team authentication controller, or starts a local in-memory token session. The token is cleared on sign-out.

| File | Responsibility |
| --- | --- |
| lib/main.dart, lib/marketplace/marketplace_button.dart | One entry on the existing home; opens the module without changing other modules |
| lib/marketplace/market_screen.dart, listing_detail.dart | Catalog, filters, details, contacts, management and pickup weather |
| lib/marketplace/forms.dart | Sign-in, filtering and grower forms |
| lib/marketplace/market_api.dart, market_bootstrap.dart | HTTP, tokens, JSON, API origin and theme |
| lib/main_marketplace.dart | Optional standalone module entry for development |
| Django marketplace/api_urls.py, api_views.py, serializers.py | URLs, authorization, input validation and response data |
| Django marketplace/models.py, catalog.py, forms.py, weather.py | Data and rules shared with the web marketplace |

### API contract

The new URLs start with **/api/marketplace/**. The original website and its session-based /marketplace/api/ routes stay available. Mobile requests send Accept: application/json; authenticated requests send **Authorization: Token TOKEN**. Write requests use application/json. The mobile marketplace ignores website session cookies, including in the local browser preview.

| Method & path | Access | Response |
| --- | --- | --- |
| POST /api/auth/login/ | Public; username + password | 200: shared token + profile/role flags |
| POST /api/auth/logout/ | Valid token | 204; token revoked |
| GET /api/marketplace/listings/ | Public | 200: count, page, pages, results; 6 per page |
| GET /api/marketplace/mine/ | Signed in | 200: same wrapper; only own offers, including paused and expired |
| GET /api/marketplace/listings/{uuid}/ | Visible to requester | 200: offer; contact appears only for a signed-in member |
| POST /api/marketplace/listings/ | Grower | 201: created offer |
| PATCH or PUT /api/marketplace/listings/{uuid}/ | Owner | 200: updated offer; PATCH for partial updates |
| DELETE /api/marketplace/listings/{uuid}/ | Owner | 204: no body |
| GET /api/marketplace/listings/{uuid}/pickup-weather/ | Visible to requester | 200: source, city, timezone, fetched_at, results; 503 if upstream unavailable |

The catalogue accepts q, category, city, area, grower, availability (now/any), price_type (free/paid), max_price, sort (newest/price_asc/price_desc/title) and page. A guest's normal feed includes offers available today; “Any time” also includes upcoming public offers. Paused, ended or inactive-owner offers are not in the public feed.

Example search: GET /api/marketplace/listings/?category=herbs&city=Depok&price_type=free. An empty result is successful: {"count":0,"page":1,"pages":1,"results":[]}. Stock and the amount the price applies to are separate. Below is an example write body; choose current dates if demonstrating availability.

~~~json
{"title":"Balcony basil","description":"Fresh basil for pickup in Beji.","category":"herbs","quantity":"6","unit":"bunch","price":"12000","price_quantity":"2","area":"Beji","city":"Depok","is_available":true}
~~~

POST this body to the collection. Read the id from the response and PATCH the detail with {"is_available":false}. Sending quantity zero on an available offer gives HTTP 400 with a field error; quantities may be zero on paused offers. Missing/invalid credentials for a protected action → 401; valid non-owner on a visible write → 403; hidden or absent listing → 404. No phone or email is sent in list responses. Weather needs date (Jakarta today or next two days), start_time, end_time, max_rain and max_temperature. A valid day can return no matching time slots; that is different from a service outage.

### Local demo

Use sibling checkouts named **urFunFarming** (Django, with the Marketplace API patch) and **urFunFarming_mobile** (Flutter, with this module patch). In the mobile checkout run:

~~~sh
bash tool/demo_marketplace.sh
~~~

This sets up a local Python environment, runs migrations and seeds demo records in local SQLite, builds the standard Flutter app, and serves both on http://127.0.0.1:8000/app/. Open **Harvest Marketplace** on the home page. The original group starter remains visible around that button until the group builds its common navigation. If Flutter is not installed, the script can instead use the group preview included in the downloaded checkpoint ZIP under ~/Downloads/Marketplace-Checkpoint1/web-vorschau (or set MARKETPLACE_PREVIEW_DIR). That fallback demonstrates the marketplace against your local Django; the menu in the prebuilt preview is not in this contribution. The local seed account demo_nadia has both roles; see the web repo README for the local demo password. Run flutter test in the mobile repo or python manage.py test marketplace in the Django environment to repeat the checks. A deployed backend must provide the marketplace routes before a phone can use them.

**Manual setup:** In the web checkout, create and activate a Python 3.10+ venv, install requirements-dev.txt, run manage.py migrate and optionally manage.py seed_demo. In the mobile repo, run flutter pub get, then flutter build web --base-href /app/ and run tool/preview_marketplace.py ../urFunFarming with the Django venv Python. For a native build the default API origin is PWS; override with --dart-define=API_BASE_URL=http://127.0.0.1:8000 on the same computer. On a physical phone, use a reachable HTTPS server.

**Team handoff:** A team drawer or route can open MarketScreen(api: sharedMarketApi) directly. Only this module is supplied. Other module pages, their endpoints, the full shared README, and the SCELE submission remain team tasks.

**Sources / AI:** Prepared with OpenAI ChatGPT/Codex assistance using the [web project](https://github.com/paramitasan/urFunFarming), the [group auth API](https://github.com/paramitasan/urFunFarming/blob/main/docs/API_AUTH.md), [BMKG weather data](https://data.bmkg.go.id/prakiraan-cuaca/) and the [official final project brief](https://pbp.cs.ui.ac.id/en/assignments/group/finalterm.html).
