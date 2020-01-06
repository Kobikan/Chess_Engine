#include <cstdlib>
#include <iostream>
#include <iterator>
#include <map>
#include <queue>
#include <string>

using namespace std;

queue<string> setup() {
  queue<string> pieces;
  string high[] = {"rook  ", "knight", "bishop", "queen ",
                   "king  ", "bishop", "knight", "rook  "};

  for (string &i : high) {
    pieces.push(i);
  }
  return pieces;
}

int check(string piece, map<pair<int, int>, string> board, pair<int, int> start,
          pair<int, int> end) {
  int state = 1;
  cout << start.second << '\n';
  cout << end.second << '\n';
  cout << start.first << '\n';
  cout << end.first << '\n';
  if (piece.compare("pawn  ") == 0) {
    state =
        (start.second + 1 == end.second && start.first == end.first) ? 0 : 1;
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
  } else if (piece.compare("queen") == 0) {
    state = check("rook", board, start, end) == 0 ||
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
  if (state == 1)
    cout << "Invalid Movement" << '\n';

  return state;
}

map<pair<int, int>, string> move(map<pair<int, int>, string> board) {
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

    valid = check(board[startPosition], board, startPosition, endPosition);
  }
  board[endPosition] = board[startPosition];
  board[startPosition] = "[]    ";
  return board;
}

int main() {
  queue<string> pieces = setup();
  map<pair<int, int>, string> board;

  for (int i = 0; i <= 63; i++) {
    pair<int, int> pos(i / 8, i % 8);
    if (i < 8 || i >= 56) {
      pieces.push(pieces.front());
      board[pos] = pieces.front();
      pieces.pop();
    } else if (i < 16 || (i >= 48 && i < 56)) {
      board[pos] = "pawn  ";
    } else {
      board[pos] = "[]    ";
    }
  }

  map<pair<int, int>, string>::iterator itr;
  for (itr = board.begin(); itr != board.end(); ++itr) {
    cout << itr->second << " ";
    if (itr->first.second % 8 == 7) {
      cout << '\n';
    }
  }

  while (1) {
    board = move(board);
    for (itr = board.begin(); itr != board.end(); ++itr) {
      cout << itr->second << " ";
      if (itr->first.second % 8 == 7) {
        cout << '\n';
      }
    }
  }

  return 0;
}
