import 'package:flutter/material.dart';

class Dialer extends StatefulWidget {
  Dialer({super.key, required this.onNumberTapped, this.colorButtonDialer});
  Color? colorButtonDialer;
  Function(String) onNumberTapped;
  @override
  State<Dialer> createState() => _DialerState();
}

class _DialerState extends State<Dialer> {
  double sizeButtonNumber = 70;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildNumberButton('1', '', sizeButtonNumber),
            buildNumberButton('4', 'GHI', sizeButtonNumber),
            buildNumberButton('7', 'PQRS', sizeButtonNumber),
            buildNumberButton('*', '', sizeButtonNumber),
          ],
        ),
        const Padding(padding: EdgeInsets.only(right: 24)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildNumberButton('2', 'ABC', sizeButtonNumber),
            buildNumberButton('5', 'JKL', sizeButtonNumber),
            buildNumberButton('8', 'TUV', sizeButtonNumber),
            buildNumberButton('0', '', sizeButtonNumber),
          ],
        ),
        const Padding(padding: EdgeInsets.only(right: 24)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildNumberButton('3', 'DEF', sizeButtonNumber),
            buildNumberButton('6', 'MNO', sizeButtonNumber),
            buildNumberButton('9', 'WXYZ', sizeButtonNumber),
            buildNumberButton('#', '', sizeButtonNumber),
          ],
        ),
      ],
    );
  }

  Widget buildNumberButton(String number, String character, double size) {
    return Container(
      decoration: BoxDecoration(
          color: widget.colorButtonDialer ?? Colors.grey[300],
          borderRadius: const BorderRadius.all(Radius.circular(50))),
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: size,
      height: size,
      child: InkWell(
        onTap: () async {
          // SharedPreferences sharedPreferences =
          //     await SharedPreferences.getInstance();
          // await sharedPreferences.setBool("isEndCallFromFCM", false);
          widget.onNumberTapped(number);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              number,
              style: const TextStyle(color: Colors.black, fontSize: 25),
            ),
            const Padding(padding: EdgeInsets.only(top: 3)),
            if (character != '')
              Text(
                character,
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }
}
