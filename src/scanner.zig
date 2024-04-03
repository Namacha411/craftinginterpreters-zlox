pub const Token = struct {
    type: TokenType,
    start: usize,
    length: usize,
    line: usize,
};

pub const TokenType = enum {
    // １文字
    left_paren,
    right_paren,
    left_brace,
    right_brace,
    comma,
    dot,
    minus,
    plus,
    semicolon,
    slash,
    star,
    // １文字か２文字
    bang,
    bang_equal,
    equal,
    equal_equal,
    greater,
    greater_equal,
    less,
    less_equal,
    // リテラル
    identifire,
    string,
    number,
    // キーワード
    and_,
    class,
    else_,
    false,
    for_,
    fun,
    if_,
    nil,
    or_,
    print,
    return_,
    super,
    this,
    true,
    var_,
    while_,
    // 特殊
    error_,
    eof,
};

pub const Scanner = struct {
    source: []const u8,
    start: usize,
    current: usize,
    line: usize,

    pub fn init(source: []const u8) Scanner {
        return Scanner{
            .source = source,
            .start = 0,
            .current = 0,
            .line = 1,
        };
    }

    fn isDigit(c: u8) bool {
        return '0' <= c and c <= '9';
    }

    fn isAlpha(c: u8) bool {
        return ('a' <= c and c <= 'z') or ('A' <= c and c <= 'Z') or c == '_';
    }

    pub fn scanToken(self: *Scanner) Token {
        self.start = self.current;
        if (self.isAtEnd()) {
            return self.makeToken(TokenType.eof);
        }
        var c = self.advance();
        if (isDigit(c)) {
            return self.number();
        }
        return switch (c) {
            // １文字
            '(' => self.makeToken(TokenType.left_paren),
            ')' => self.makeToken(TokenType.right_paren),
            '{' => self.makeToken(TokenType.left_brace),
            '}' => self.makeToken(TokenType.right_brace),
            ';' => self.makeToken(TokenType.semicolon),
            ',' => self.makeToken(TokenType.comma),
            '.' => self.makeToken(TokenType.dot),
            '-' => self.makeToken(TokenType.minus),
            '+' => self.makeToken(TokenType.plus),
            '/' => self.makeToken(TokenType.slash),
            '*' => self.makeToken(TokenType.star),
            // ２文字
            '!' => self.makeToken(if (self.match('=')) TokenType.bang_equal else TokenType.bang),
            '=' => self.makeToken(if (self.match('=')) TokenType.equal_equal else TokenType.equal),
            '<' => self.makeToken(if (self.match('=')) TokenType.less_equal else TokenType.less),
            '>' => self.makeToken(if (self.match('=')) TokenType.greater_equal else TokenType.greater),
            // リテラル
            '"' => self.string(),
            else => self.errorToken("Unexpected character."),
        };
    }

    fn isAtEnd(self: *Scanner) bool {
        return self.source[self.current] == '\x00';
    }

    fn advance(self: *Scanner) u8 {
        self.current += 1;
        return self.source[self.current - 1];
    }

    fn peek(self: *Scanner) u8 {
        return self.source[self.current];
    }

    fn peekNext(self: *Scanner) u8 {
        return if (self.isAtEnd()) '\x00' else self.source[self.current + 1];
    }

    fn match(self: *Scanner, expected: u8) bool {
        if (self.isAtEnd()) {
            return false;
        }
        if (self.current != expected) {
            return false;
        }
        self.current += 1;
        return true;
    }

    fn makeToken(self: *Scanner, t: TokenType) Token {
        var token = Token{
            .type = t,
            .start = self.start,
            .length = self.current - self.start,
            .line = self.line,
        };
        return token;
    }

    fn errorToken(self: *Scanner, message: []const u8) Token {
        var token = Token{
            .type = TokenType.error_,
            .start = 0,
            .length = message.len,
            .line = self.line,
        };
        return token;
    }

    fn skipWhiteSpace(self: *Scanner) void {
        while (true) {
            switch (self.peek()) {
                ' ' | '\r' | '\t' => {
                    self.advance();
                    break;
                },
                '\n' => {
                    self.line += 1;
                    self.advance();
                    break;
                },
                '/' => {
                    if (self.peekNext() == '/') {
                        while (self.peek() != '\n' and !self.isAtEnd()) {
                            self.advance();
                        }
                    } else {
                        return;
                    }
                },
                else => {
                    return;
                },
            }
        }
    }

    fn string(self: *Scanner) Token {
        while (self.peek() != '"' and !self.isAtEnd()) {
            if (self.peek() == '\n') {
                self.line += 1;
            }
            self.advance();
        }
        if (self.isAtEnd()) {
            return self.errorToken("Unterminated string.");
        }
        self.advance();
        return self.makeToken(TokenType.string);
    }

    fn number(self: *Scanner) Token {
        while (isDigit(self.peek())) {
            self.advance();
        }
        if (self.peek() == '.' and isDigit(self.peekNext())) {
            self.advance();
            while (isDigit(self.peek())) {
                self.advance();
            }
        }
        return self.makeToken(TokenType.number);
    }

    fn identifierType() TokenType {
        return TokenType.identifire;
    }

    fn identifier(self: *Scanner) Token {
        while (isAlpha(self.peek()) or isDigit(self.peek())) {
            self.advance();
        }
        return self.makeToken(identifierType());
    }
};
