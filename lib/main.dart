// ignore_for_file: unnecessary_null_comparison
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'Flutter Riverpod Course 3',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        home: const HomePage(),
      ),
    ),
  );
}

const value = '🌧'; // emoji gotten by using windows logo + .

enum City {
  stockholm,
  paris,
  tokyo,
  newYork,
}

typedef WeatherEmoji = String;
Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(
    const Duration(seconds: 1),
    () =>
        {
          City.stockholm: '❄',
          City.paris: '🌧',
          City.tokyo: '💨',
        }[city] ??
        '☀',
  );
}

const unknownWeatherEmoji = '🤷‍♀️';

// Now we use a State Provider, which keeps hold of a value/state that can be changed.
// Here, the provider below will be changed by the UI.
final currentCityProvider = StateProvider<City?>(
  (ref) => null,
);

// Provider below, listens to changes to in the provider above and the UI reads from this provider.
final weatherProvider = FutureProvider<WeatherEmoji>(
  (ref) {
    final city = ref.watch(currentCityProvider);
    if (city != null) {
      return getWeather(city);
    } else {
      return unknownWeatherEmoji;
    }
  },
);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // First read the current weather
    final currentWeather = ref.watch(
      weatherProvider,
    );
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Weather'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
        child: Column(
          children: [
            // Here we parse the widget that builds the weather emoji
            currentWeather.when(
              data: (data) => Text(
                data,
                style: const TextStyle(
                  fontSize: 105,
                ),
              ),
              error: (_, __) => const Text('Error - No Weather'),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: City.values.length,
                itemBuilder: (context, index) {
                  final city = City.values[index];
                  final isSelected = city ==
                      ref.watch(
                          currentCityProvider); // Here, checks if this city is currently selected
                  return ListTile(
                    title: Text(
                      city.toString(),
                    ),
                    trailing: isSelected ? const Icon(Icons.check) : null,
                    onTap: () {
                      // Here we only want to take a snapshot of what the current state is in the provider.
                      ref
                          .read(
                            currentCityProvider.notifier,
                          )
                          .state = city;
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
