import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CityInputScreen(),
    );
  }
}

class CityInputScreen extends StatefulWidget {
  @override
  _CityInputScreenState createState() => _CityInputScreenState();
}

class _CityInputScreenState extends State<CityInputScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.indigo],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Weather App',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Enter city',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                onSubmitted: (value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherScreen(city: value),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WeatherScreen(city: _cityController.text),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Get Weather Report',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherScreen extends StatelessWidget {
  final String city;
  WeatherScreen({required this.city});

  Future<Map<String, dynamic>> getWeather() async {
    final String apiKey = 'ee8d6da7e79fddaf4a41cc48db6bf6e0';
    final String apiUrl = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/weather',
      {'q': city, 'appid': apiKey},
    ).toString();

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Return an empty map in case of an error
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: FutureBuilder(
        future: getWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final weatherData = snapshot.data as Map<String, dynamic>;

            // Handle error case gracefully
            if (weatherData.isEmpty) {
              return Center(
                child: Text('Failed to load weather data'),
              );
            }

            final mainWeather = weatherData['weather'][0]['main'];
            final description = weatherData['weather'][0]['description'];
            final temperatureKelvin = weatherData['main']['temp'];
            final temperatureCelsius =
                kelvinToCelsius(temperatureKelvin).toStringAsFixed(1);
            final windSpeed = weatherData['wind']['speed'];
            final clouds = weatherData['clouds']['all'];
            final cityName = weatherData['name'];

            final cardBackgroundColor = getBackgroundColor(mainWeather);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 500,
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: cardBackgroundColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$cityName',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '$mainWeather - $description',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Temperature: $temperatureCelsius°C',
                        style: getWeatherTextStyle(),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Wind Speed: $windSpeed m/s',
                        style: getWeatherTextStyle(),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Clouds: $clouds%',
                        style: getWeatherTextStyle(),
                      ),
                      SizedBox(height: 20),
                      // Weather Emojis
                      getWeatherEmoji(mainWeather),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // Function to display weather emojis based on weather condition
  Widget getWeatherEmoji(String mainWeather) {
    String emoji = '';

    switch (mainWeather.toLowerCase()) {
      case 'clear':
        emoji = '☀️'; // Sunny
        break;
      case 'clouds':
        emoji = '☁️'; // Cloudy
        break;
      case 'rain':
        emoji = '🌧️'; // Rainy
        break;
      case 'snow':
        emoji = '❄️'; // Snowy
        break;
      default:
        emoji = ''; // Unknown
    }

    return Text(
      emoji,
      style: TextStyle(fontSize: 40),
    );
  }

  double kelvinToCelsius(double kelvin) {
    return kelvin - 273.15;
  }

  Color getBackgroundColor(String mainWeather) {
    switch (mainWeather.toLowerCase()) {
      case 'clear':
        return Colors.orangeAccent;
      case 'clouds':
        return Color.fromARGB(255, 105, 190, 233);
      case 'rain':
        return Colors.indigo;
      case 'snow':
        return Colors.lightBlueAccent;
      default:
        return Color.fromARGB(255, 121, 50, 164);
    }
  }

  TextStyle getWeatherTextStyle() {
    return TextStyle(
      fontSize: 18,
      color: Colors.white,
    );
  }
}
