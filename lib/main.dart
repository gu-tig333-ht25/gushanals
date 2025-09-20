import 'package:flutter/material.dart';
//Utkast 1, endast utseende och design på appen

void main() {
  runApp(const MyApp()); //Startar appen med MyApp
}

//Definiera färgerna vi vill använda, så det bilr lättare att använda dem
//Har ändrat färgerna en heldel, så namnen passar inte färgen förtillfället
const Color lightPink = Color.fromARGB(169, 239, 231, 213); 
const Color darkPink = Color.fromRGBO(100, 36, 46, 10);  

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TIG333 TODO',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(169, 239, 231, 213), //Bakgrund på sidorna, blir standard genom "scaffold"
        
        //Färgerna på toppbaren/appbaren
        appBarTheme: const AppBarTheme(
          backgroundColor: darkPink,
          foregroundColor: Colors.white, //Vit text i appbaren
        ),

        //Färger/tema för +knappen i hörnet
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: darkPink,
          foregroundColor: Colors.white,
        ),

        //Tema för alla checkboxar
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all(const Color.fromARGB(255, 255, 255, 255)),
        ),

        //Tema för text knappar, dvs "lägg till" i detta fallet
        textButtonTheme: TextButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            backgroundColor: darkPink,
            foregroundColor: Colors.white,
          )
        ),
      ),
      home: const TodoListPage(), //Första sidan mans er
    );
  }
}

//Förstasidan, dvs listan med todos
class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( //Funktinerna/designen som finns i appbaren på toppen av sidan
        centerTitle: true, //Centrerar titeln, dvs TIG333
        title: const Text("TIG333 TODO"),
        actions: [

          // Meny för filtrering
          PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder: (context) => const [
              PopupMenuItem(value: "all", child: Text("all")),
              PopupMenuItem(value: "done", child: Text("done")),
              PopupMenuItem(value: "undone", child: Text("undone")),
            ],
          )
        ],
      ),
      body: ListView( //ListView gör att vi kan skrolla om listan skulle bli för lång
        children: const [
          TodoItem(title: "Rita"),
          TodoItem(title: "Jobba på inlämningsuppgift", done: true),
          TodoItem(title: "Städa"),
          TodoItem(title: "Gå ut med hundarna"),
          TodoItem(title: "Shoppa", done : true),
          TodoItem(title: "Plugga"),
        ],
      ),

      //Plus-knappen i hörnet, samt att man blir skickad till ADD-sidan om man trycker på den 
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoPage()),
          );
        },
        child: const Icon(Icons.add), //Plusikonen
      ),
    );
  }
}

//Widget för varje Todo-rad 
class TodoItem extends StatelessWidget {
  final String title; //Texten på todo
  final bool done; //Om todon är färdig eller inte

  const TodoItem({super.key, required this.title, this.done = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, //Gör todo rutan vit
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), //Ger rutan rundade hörn
      ),
      elevation: 3, //Ger liten skugga under Card
      child: ListTile( //Standard widget för rader med ikon och text
        leading: Checkbox(
          value: done, //Om todon är färdig eller inte 
          activeColor: darkPink, //Checkbox är mörkrosa
          onChanged: (value) {}, 
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : null, //Stryker todon om den är färdig
            color: Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.close, color: Colors.black), //"x" knappen till höger om todon
      ),
    );
  }
}


//Andrasidan där man lägger till todo
class AddTodoPage extends StatelessWidget {
  const AddTodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( //Innuti finns funktioner som ska finnas i appbaren

        //Pil ikon för att gå tillbaka till todo listan/sidan
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), //Gå tillbaka när man klickat på knappen
        ),

        //Titeln i toppbaren/appbaren
        title: const Text("TIG333 TODO"),
        centerTitle: true
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), //Padding ger luft mellan innehållet 
        child: Column( //Staplar widgets vertikalt
          crossAxisAlignment: CrossAxisAlignment.start, //Vänsterjusterar innehållet
          children: [
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(), //Ramen
                hintText: "Vad vill du lägga till?", //Texten i ramen innan den används
                filled: true,
                fillColor: Colors.white, //Vit bakgrund i ramen
              ),
            ),
            const SizedBox(height: 16), //Mellanrum
            Center(
              child: TextButton.icon( //Vad som händer när amn klickar på ADD knappen, samt dens färg
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.white), //+ ikonen
                label: const Text("LÄGG TILL"), //Texten i rutan
              ),
            )
          ],
        ),
      ),
    );
  }
}

