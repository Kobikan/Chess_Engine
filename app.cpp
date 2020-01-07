#include "Piece.h"
#include <cstdlib>
#include <iostream>
#include <iterator>
#include <map>
#include <queue>
#include <string>
// Purely for terminal Remove once Opencl is integrated
#include <windows.h>
using namespace std;

// ENUMs for Traversal of rook and bishop
enum rookDirection { North, East, West, South } rookDir;
enum bishopDirection { NorthEast, NorthWest, SouthEast, SouthWest } bishopDir;
enum check { Null, Check, CheckMate } checkState;

// Setup for queue used for chess placement intiation
queue<string> setup() {
  queue<string> pieces;
  string high[] = {"rook  ", "knight", "bishop", "queen ",
                   "king  ", "bishop", "knight", "rook  "};

  for (string &i : high) {
    pieces.push(i);
  }
  return pieces;
}

// Checks if the traversal is blocked
bool checkIfBlocked(string piece, map<pair<int, int>, Piece> board,
                    pair<int, int> start, pair<int, int> end) {
  bool blocked = false;
  if (piece.compare("rook  ") == 0) {
    int xTraversal, yTraversal, rookTraversal;
    pair<int, int> position = start;

    yTraversal = start.first - end.first;
    xTraversal = start.second - end.second;
    rookDir = xTraversal == 0 ? yTraversal > 0 ? North : South
                              : xTraversal > 0 ? West : East;
    rookTraversal = abs(xTraversal == 0 ? yTraversal : xTraversal);
    while (rookTraversal != 1) {
      if (rookDir == North) {
        position = make_pair(position.first - 1, position.second);
      } else if (rookDir == East) {
        position = make_pair(position.first, position.second + 1);
      } else if (rookDir == South) {
        position = make_pair(position.first + 1, position.second);
      } else if (rookDir == West) {
        position = make_pair(position.first, position.second - 1);
      }
      rookTraversal--;
      cout << position.first << '\n';
      cout << board[position].getPiece().compare("[]    ") << '\n';

      blocked =
          board[position].getPiece().compare("[]    ") != 0 ? true : false;
    }
  } else if (piece.compare("bishop") == 0) {
    int xTraversal, yTraversal, bishopTraversal;
    pair<int, int> position = start;

    yTraversal = start.first - end.first;
    xTraversal = start.second - end.second;
    bishopDir = yTraversal > 0 ? xTraversal > 0 ? NorthEast : NorthWest
                               : xTraversal > 0 ? SouthEast : SouthWest;
    bishopTraversal = abs(xTraversal);
    while (bishopTraversal != 1) {
      cout << "Traversal" << bishopTraversal << '\n';
      cout << bishopDir << '\n';
      if (bishopDir == NorthEast) {
        position = make_pair(position.first + 1, position.second + 1);
      } else if (bishopDir == NorthWest) {
        position = make_pair(position.first + 1, position.second - 1);
      } else if (bishopDir == SouthEast) {
        position = make_pair(position.first - 1, position.second + 1);
      } else if (bishopDir == SouthWest) {
        position = make_pair(position.first - 1, position.second - 1);
      }
      bishopTraversal--;
      cout << position.first << '\n';
      cout << board[position].getPiece().compare("[]    ") << '\n';

      blocked =
          board[position].getPiece().compare("[]    ") != 0 ? true : false;
    }
  } else if (piece.compare("queen") == 0) {
    blocked = checkIfBlocked("rook  ", board, start, end) ||
              checkIfBlocked("bishop", board, start, end);
  }
  return blocked;
}

// Checks if the move made id applicable for the piece
int check(string piece, map<pair<int, int>, Piece> board, pair<int, int> start,
          pair<int, int> end) {
  int state = 1;
  cout << start.second << '\n';
  cout << end.second << '\n';
  cout << start.first << '\n';
  cout << end.first << '\n';
  if (piece.compare("pawn  ") == 0) {
    state =
        (start.second == end.second && start.first + 1 == end.first) ? 0 : 1;
  } else if (piece.compare("rook  ") == 0) {
    cout << piece << '\n';
    state = (start.second == end.second && start.first != end.first ||
             start.second != end.second && start.first == end.first)
                ? 0
                : 1;

  } else if (piece.compare("knight") == 0) {
    state = ((start.second + 1 == end.second && start.first + 3 == end.first) ||
             (start.second + 1 == end.second && start.first - 3 == end.first) ||
             (start.second - 1 == end.second && start.first + 3 == end.first) ||
             (start.second - 1 == end.second && start.first - 3 == end.first) ||
             (start.second + 3 == end.second && start.first + 1 == end.first) ||
             (start.second + 3 == end.second && start.first - 1 == end.first) ||
             (start.second - 3 == end.second && start.first + 1 == end.first) ||
             (start.second - 3 == end.second && start.first - 1 == end.first))
                ? 0
                : 1;

  } else if (piece.compare("bishop") == 0) {
    state = (abs(start.second - end.second) == abs(start.first - end.first))
                ? 0
                : 1;
  } else if (piece.compare("queen ") == 0) {
    state = check("rook  ", board, start, end) == 0 ||
                    check("bishop", board, start, end) == 0
                ? 0
                : 1;
  } else if (piece.compare("king") == 0) {
    state = ((start.second + 1 == end.second && start.first + 1 == end.first) ||
             (start.second + 1 == end.second && start.first - 1 == end.first) ||
             (start.second - 1 == end.second && start.first + 1 == end.first) ||
             (start.second - 1 == end.second && start.first - 1 == end.first) ||
             (start.second + 1 == end.second && start.first == end.first) ||
             (start.second - 1 == end.second && start.first == end.first) ||
             (start.second == end.second && start.first + 1 == end.first) ||
             (start.second == end.second && start.first - 1 == end.first))
                ? 0
                : 1;
  }
  if (state == 1) {
    cout << "Invalid Movement" << '\n';
  } else if (checkIfBlocked(piece, board, start, end)) {
    cout << "Invalid Movements" << '\n';
    state = 1;
  }

  return state;
}

// Moves the piece
map<pair<int, int>, Piece> move(map<pair<int, int>, Piece> board) {
  int valid = 1;
  int startX, startY;
  int endX, endY;
  pair<int, int> startPosition, endPosition;

  while (valid) {
    cout << "Choose Initial Coordinates" << '\n';
    cout << "Choose X Coordinate" << '\n';
    cin >> startX;
    cout << "Choose Y Coordinate" << '\n';
    cin >> startY;
    cout << "Choose Final Coordinates" << '\n';
    cout << "Choose X Coordinate" << '\n';
    cin >> endX;
    cout << "Choose Y Coordinate" << '\n';
    cin >> endY;

    startPosition = make_pair(startY, startX);
    endPosition = make_pair(endY, endX);
    cout << startX - endX << '\n';
    cout << startY - endY << '\n';
    if (board[endPosition].getSide() != board[startPosition].getSide()) {
      valid = check(board[startPosition].getPiece(), board, startPosition,
                    endPosition);
    }
  }
  checkState = board[endPosition].getPiece() == "king  " ? CheckMate : Null;
  board[endPosition] = board[startPosition];
  Piece empty("[]    ", 3);
  board[startPosition] = empty;
  return board;
}

int main() {
  HANDLE consoleTextColor;
  consoleTextColor = GetStdHandle(STD_OUTPUT_HANDLE);

  queue<string> pieces = setup();
  // Because the way Map works it automatically maps based on the First number
  // hence the position is based Y and X rather than X and Y
  map<pair<int, int>, Piece> board;

  for (int i = 0; i <= 63; i++) {
    pair<int, int> pos(i / 8, i % 8);
    if (i < 8) {
      pieces.push(pieces.front());
      Piece test1(pieces.front(), 1);
      board[pos] = test1;
      pieces.pop();
    } else if (i < 16) {
      Piece test1("pawn  ", 1);
      board[pos] = test1;
    } else if (i >= 56) {
      pieces.push(pieces.front());
      Piece test1(pieces.front(), 2);
      board[pos] = test1;
      pieces.pop();
    } else if ((i >= 48 && i < 56)) {
      Piece test1("pawn  ", 2);
      board[pos] = test1;
    } else {
      Piece test1("[]    ", 3);
      board[pos] = test1;
    }
  }

  map<pair<int, int>, string>::iterator itr;
  // for (itr = board.begin(); itr != board.end(); ++itr) {
  //   cout << itr->second << " ";
  //   if (itr->first.second % 8 == 7) {
  //     cout << '\n';
  //   }
  // }

  for (int i = 0; i <= 7; i++) {
    for (int j = 0; j <= 7; j++) {
      int color = board[make_pair(i, j)].getSide();
      SetConsoleTextAttribute(consoleTextColor, color);
      cout << board[make_pair(i, j)].getPiece() << " ";
    }
    cout << '\n';
  }

  while (checkState != CheckMate) {
    int color = 15;
    SetConsoleTextAttribute(consoleTextColor, color);
    board = move(board);
    for (int i = 0; i <= 7; i++) {
      for (int j = 0; j <= 7; j++) {
        color = board[make_pair(i, j)].getSide();
        SetConsoleTextAttribute(consoleTextColor, color);
        cout << board[make_pair(i, j)].getPiece() << " ";
      }
      cout << '\n';
    }
  }

  return 0;
}
