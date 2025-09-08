import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

// ---------------------------
// ROTAS
// ---------------------------
class AppRoutes {
  static const home = '/';
  static const details = '/details';

  static Route<dynamic> generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => SportListScreen());
      case details:
        final args = settings.arguments as SportDetailScreenArguments;
        return MaterialPageRoute(
          builder: (_) => SportDetailScreen(sport: args.sport),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text("Erro"))),
        );
    }
  }
}

class SportDetailScreenArguments {
  final Sport sport;
  SportDetailScreenArguments({required this.sport});
}

// ---------------------------
// MODELO DE FOOD
// ---------------------------
class Sport {
  final int id;
  final String name;
  final String image;
  final String popularity;
  final String description;

  Sport({
    required this.id,
    required this.name,
    required this.image,
    required this.popularity,
    required this.description,
  });

  factory Sport.fromJson(Map<String, dynamic> json) => Sport(
    id: json['id'] as int,
    name: json['name'] as String,
    image: json['image'] as String,
    popularity: json['popularity'] as String,
    description: json['description'] as String,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'popularity': popularity,
    'description': description,
  };
}

// ---------------------------
// APP PRINCIPAL
// ---------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: retornar MaterialApp usando AppRoutes.routes
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lista de esportes',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoutes,
    );
  }
}

// ---------------------------
// TELA DE LISTA
// ---------------------------
class SportListScreen extends StatefulWidget {
  const SportListScreen({super.key});

  @override
  State<SportListScreen> createState() => _SportListScreenState();
}

class _SportListScreenState extends State<SportListScreen> {
  List<Sport> sports = [];
  Sport? lastViewed;

  @override
  void initState() {
    super.initState();
    _loadSports();
    _loadLastViewed();
  }

  Future<List<Sport>> _loadSports() async {
    // TODO: carregar JSON de assets/data/foods.json e preencher lista foods
    final jsonstr = await rootBundle.loadString('assets/data/sports.json');
    final list = jsonDecode(jsonstr) as List;
    sports =
        list.map((e) => Sport.fromJson(Map<String, dynamic>.from(e))).toList();
    return sports;
  }

  Future<void> _loadLastViewed() async {
    // TODO: carregar último food visto de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keylastViewedSport);
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        lastViewed = Sport.fromJson(map);
      } catch (_) {}
    }
  }

  static const String _keylastViewedSport = 'ultimo_visto';
  Future<void> _saveLastViewed(Sport sport) async {
    // TODO: salvar food em SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keylastViewedSport, jsonEncode(sport.toJson()));
  }

  void _openDetails(Sport sport) async {
    // TODO: abrir SportDetailScreen via Navigator e salvar como último visto
    _saveLastViewed(sport);
    _loadLastViewed();
    if (mounted) {
      Navigator.pushNamed(
        context,
        AppRoutes.details,
        arguments: SportDetailScreenArguments(sport: sport),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: montar Scaffold com AppBar, seção "Último prato visto" e lista de foods
    return Scaffold(
      appBar: AppBar(title: Text("Sportes favoritos")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // LastViewedCard(sport: lastViewed, onTap: () {}),
          SizedBox(height: 16),
          FutureBuilder<List<Sport>>(
            future: _loadSports(), 
            builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){ 
            return const Center(child: CircularProgressIndicator());
            } else if(snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar obras'),);
            }else if(!snapshot.hasData || snapshot.data!.isEmpty){
              return const Center(child: Text('nenhuma obra encontrada'));
            }else{
              final sp = snapshot.data!;
              return Expanded(
                child: ListView.builder(
                  itemCount: sp.length,
                  itemBuilder: (context, index){
                    final s = sp[index];
                    return GestureDetector(
                      onTap: (){_openDetails(s);},
                      child: Sportcard(sport: s));
                
                  }),
              );
            }
          })
        ],
      ),
    );
  }
}

// ---------------------------
// WIDGET: CARD ÚLTIMO FOOD
// ---------------------------
class LastViewedCard extends StatelessWidget {
  final Sport? sport;
  final VoidCallback? onTap;

  const LastViewedCard({super.key, this.sport, this.onTap});

  @override
  Widget build(BuildContext context) {
    // TODO: retornar Card com informações do último food ou SizedBox.shrink() se null
    return Container();
  }
}

// ---------------------------
// WIDGET: CARD FOOD
// ---------------------------
class Sportcard extends StatelessWidget {
  final Sport sport;
  final VoidCallback? onTap;

  const Sportcard({super.key, required this.sport, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                sport.image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ____) => Container(
                      color: Colors.grey[300],
                      height: 200,
                      child: const Icon(Icons.broken_image, size: 60),
                    ),
              ),
            ),
            SizedBox(width: 8),
            Column(
              children: [
                Text(
                  sport.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6,),
                Text(sport.description, style: TextStyle(fontSize: 14),),
                SizedBox(height: 4,),
                Text(sport.popularity, style: TextStyle(fontSize: 14),)
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------
// TELA DE DETALHES
// ---------------------------
class SportDetailScreen extends StatefulWidget {
  final Sport sport;
  const SportDetailScreen({super.key, required this.sport});

  @override
  State<SportDetailScreen> createState() => _SportDetailScreenState();
}

class _SportDetailScreenState extends State<SportDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: recuperar produto via ModalRoute e exibir detalhes (imagem, nome, estrelas, descrição e preços)
    return Container();
  }
}
