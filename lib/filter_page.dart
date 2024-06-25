import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ),
);

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedConnectorType = 'AC';  // Varsayılan değerler güncellendi
  String selectedSocketType = 'Type 1';  // Varsayılan değerler güncellendi
  String selectedPaymentType = 'Only Reservation';  // Varsayılan değerler güncellendi
  String selectedUserRating = '1>';  // Varsayılan değerler güncellendi
  String selectedLocationType = 'Gas Station';  // Varsayılan değerler güncellendi

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Filters"),
        backgroundColor: Colors.green,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green, Colors.greenAccent],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "Filters",
                style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  children: <Widget>[
                    filterOption("Connector types", selectedConnectorType, ['AC', 'DC']),
                    filterOption("Socket types", selectedSocketType, ['Type 1', 'Type 2', 'CCS', 'CHAdeMO']),
                    filterOption("Payment", selectedPaymentType, ['Only Reservation', 'Credit/Bank Card']),
                    filterOption("User Rating", selectedUserRating, ['ALL', '2>', '3>', '4>', '5>']),
                    filterOption("Location Type", selectedLocationType, ['Gas Station', 'Restaurant', 'Hotel', 'Mall', 'Parking Lot']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),  // Raise the button from the bottom
        child: FloatingActionButton.extended(
          onPressed: () {
            // TODO: Implement search functionality
          },
          label: Text('Search'),
          icon: Icon(Icons.search),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  Widget filterOption(String title, String selectedValue, List<String> options) {
    return InkWell(
      onTap: () => _showFilterOptions(title, options),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions(String title, List<String> options) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(options[index]),
                onTap: () {
                  setState(() {
                    switch (title) {
                      case 'Connector types':
                        selectedConnectorType = options[index];
                        break;
                      case 'Socket types':
                        selectedSocketType = options[index];
                        break;
                      case 'Payment':
                        selectedPaymentType = options[index];
                        break;
                      case 'User Rating':
                        selectedUserRating = options[index];
                        break;
                      case 'Location Type':
                        selectedLocationType = options[index];
                        break;
                    }
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }
}
