import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash-Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GridInputScreen()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/bird_2.jpg', width: 150.0, height: 150.0),
            const SizedBox(height: 20.0),
            const Text(
              'Classico',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            const CircularProgressIndicator(), // Show a circular progress indicator
          ],
        ),
      ),
    );
  }
}

class GridInputScreen extends StatefulWidget {
  const GridInputScreen({Key? key}) : super(key: key);

  @override
  _GridInputScreenState createState() => _GridInputScreenState();
}

class _GridInputScreenState extends State<GridInputScreen> {
  int m = 0;
  int n = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grid Input'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Rows (m):"),
                const SizedBox(width: 10),
                Container(
                  width: 50,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        m = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Columns (n):"),
                const SizedBox(width: 10),
                Container(
                  width: 50,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        n = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Validate input and navigate to the next screen
                if (m > 0 && n > 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GridScreen(m: m, n: n),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter valid values for m and n.'),
                    ),
                  );
                }
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class GridScreen extends StatefulWidget {
  final int m;
  final int n;

  const GridScreen({Key? key, required this.m, required this.n}) : super(key: key);

  @override
  _GridScreenState createState() => _GridScreenState();
}

class _GridScreenState extends State<GridScreen> {
  late List<List<String>> grid;

  void validateAndNavigate() {
    // Validate input and navigate to the next screen
    if (grid.any((row) => row.any((cell) => cell.isNotEmpty))) {
      // Check if all entered characters are alphabets
      if (grid.every((row) => row.every((cell) => cell.toUpperCase().contains(RegExp(r'[A-Z]'))))) {
        // Navigate to the next screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TextSearchScreen(
              m: widget.m,
              n: widget.n,
              enteredCharactersGrid: grid,
              enteredCharacters: [],
              searchText: '',
            ),
          ),
        );
      } else {
        // Show a snackbar for invalid characters
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all cells with valid alphabets.'),
          ),
        );
      }
    } else {
      // Show a snackbar for an empty grid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill at least one cell with an alphabet.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    grid = List.generate(widget.m, (index) => List.filled(widget.n, ""));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grid Display'),
      ),
      body: SizedBox( // Wrap with a container to constrain height
        height: 500, // Set a fixed height or use some constraints
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('Grid Size: ${widget.m} x ${widget.n}'),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.n,
                ),
                itemBuilder: (context, index) {
                  int row = index ~/ widget.n;
                  int col = index % widget.n;

                  TextEditingController controller = TextEditingController(text: grid[row][col]);

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controller,
                      onChanged: (value) {
                        setState(() {
                          // Ensure only one alphabet is entered
                          if (value.length == 1 && value.toUpperCase().contains(RegExp(r'[A-Z]'))) {
                            grid[row][col] = value.toUpperCase();
                          }
                        });
                      },
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                },
                itemCount: widget.m * widget.n,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: validateAndNavigate,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextSearchScreen extends StatefulWidget {
  final int m;
  final int n;
  final List<List<String>> enteredCharactersGrid;
  final List<String> enteredCharacters;
  late String searchText;

  TextSearchScreen({
    Key? key,
    required this.m,
    required this.n,
    required this.enteredCharactersGrid,
    required this.enteredCharacters,
    required this.searchText,
  }) : super(key: key);

  @override
  _TextSearchScreenState createState() => _TextSearchScreenState();
}

class _TextSearchScreenState extends State<TextSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  // Update the search text as the user types
                  widget.searchText = value.toUpperCase();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Enter Text to Search',
              ),
            ),
            const SizedBox(height: 20),
            // Display entered characters
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.n,
              ),
              itemBuilder: (context, index) {
                int row = index ~/ widget.n;
                int col = index % widget.n;

                return Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Center(
                    child: Text(widget.enteredCharactersGrid[row][col]),
                  ),
                );
              },
              itemCount: widget.m * widget.n,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (widget.searchText.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SearchResultScreen(
                          m: widget.m,
                          n: widget.n,
                          enteredCharactersGrid: widget.enteredCharactersGrid,
                          searchText: widget.searchText,
                          enteredCharacters: [],
                        );
                      },
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid search text.'),
                    ),
                  );
                }
              },
              child: const Text('Search in Grid'),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchResultScreen extends StatefulWidget {
  final int m;
  final int n;
  final List<String> enteredCharacters;
  final String searchText;
  final List<List<String>> enteredCharactersGrid;

  const SearchResultScreen({
    Key? key,
    required this.m,
    required this.n,
    required this.enteredCharacters,
    required this.searchText,
    required this.enteredCharactersGrid,
  }) : super(key: key);

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  List<List<bool>> highlightGrid = [];

  @override
  void initState() {
    super.initState();
    searchAndHighlight(widget.searchText);
  }

  bool searchAndHighlight(String searchText) {
    // Reset previous highlights
    highlightGrid = List.generate(widget.m, (row) => List.filled(widget.n, false));

    bool isTextPresent(int row, int col, int rowIncrement, int colIncrement) {
      for (int i = 0; i < searchText.length; i++) {
        int currentRow = row + i * rowIncrement;
        int currentCol = col + i * colIncrement;

        if (currentRow < 0 ||
            currentRow >= widget.m ||
            currentCol < 0 ||
            currentCol >= widget.n) {
          break;
        }

        if (widget.enteredCharactersGrid[currentRow][currentCol] !=
            (searchText[i] ?? '')) {
          break;
        }

        if (i == searchText.length - 1) {
          for (int j = 0; j < searchText.length; j++) {
            highlightGrid[row + j * rowIncrement][col + j * colIncrement] = true;
          }
          return true;
        }
      }
      return false;
    }

    for (int row = 0; row < widget.m; row++) {
      for (int col = 0; col < widget.n; col++) {
        Navigator.of(context).pop();
        if (widget.enteredCharactersGrid[row][col] == (searchText[0] ?? '')) {
          // Check in east direction
          if (isTextPresent(row, col, 0, 1)) return true;

          // Check in south direction
          if (isTextPresent(row, col, 1, 0)) return true;

          // Check in south-east direction
          if (isTextPresent(row, col, 1, 1)) return true;
        }
      }
    }

    setState(() {});
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Result'),
      ),
      body: Column(
        children: [
          // Display highlighted grid
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.n,
            ),
            itemBuilder: (context, index) {
              int row = index ~/ widget.n;
              int col = index % widget.n;
              return GestureDetector(
                onTap: () {
                  // On cell tap, change the search text and highlight again
                  searchAndHighlight(widget.enteredCharactersGrid[row][col]);
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: highlightGrid[row][col] ? Colors.yellow : Colors.white,
                  ),
                  child: Center(
                    child: Text(widget.enteredCharactersGrid[row][col]),
                  ),
                ),
              );
            },
            itemCount: widget.m * widget.n,
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) {
              // Update the search text as the user types
              searchAndHighlight(value.toUpperCase());
            },
            decoration: const InputDecoration(
              labelText: 'Enter Text to Search',
            ),
          ),
        ],
      ),
    );
  }
}
