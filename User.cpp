#include "User.h"

User::User() {
  color = "";
  side = 0;
}

User::User(string chessColor, int player) {
  color = chessColor;
  side = player;
}

string User::getColor() const { return color; }

int User::getSide() const { return side; }
