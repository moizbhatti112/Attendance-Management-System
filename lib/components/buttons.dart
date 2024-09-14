import 'package:flutter/material.dart';

class Mybutton extends StatefulWidget {
  final Widget child;
  const Mybutton({
    super.key,
    required this.child
    });

  @override
  State<Mybutton> createState() => _MybuttonState();
}

class _MybuttonState extends State<Mybutton> {



  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      height: MediaQuery.of(context).size.height * 0.23,
      width: MediaQuery.of(context).size.width * 0.42,
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 233, 231, 231),
          border: Border.all(color: Colors.deepPurple, width: 3),
          borderRadius: BorderRadius.circular(20)),
      child: widget.child
    );
  }
}
