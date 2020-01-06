#include "Piece.h"

Piece::Piece() {
  type = "[]    ";
  side = 0;
}

Piece::Piece(string chessPiece, int player) {
  type = chessPiece;
  side = player;
}

string Piece::getPiece() const { return type; }

int Piece::getSide() const { return side; }
