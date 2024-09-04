import Nat32 "mo:base/Nat32";

import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Float "mo:base/Float";
import Char "mo:base/Char";
import IC "mo:ic";
import Iter "mo:base/Iter";

actor {
  let ic : IC.Service = actor("aaaaa-aa");

  func limitIter<T>(iter : Iter.Iter<T>, limit : Nat) : Iter.Iter<T> {
    var i = 0;
    object {
      public func next() : ?T {
        if (i >= limit) { null }
        else {
          i += 1;
          iter.next()
        }
      };
    }
  };

  func textToFloat(t : Text) : ?Float {
    var f : Float = 0;
    var exp : Float = 0;
    var decimal = false;
    for (c in t.chars()) {
      if (c == '.') {
        decimal := true;
      } else if (c >= '0' and c <= '9') {
        let digit : Float = Float.fromInt(Nat32.toNat(Char.toNat32(c) - Char.toNat32('0')));
        if (decimal) {
          exp -= 1;
          f += digit * Float.pow(10, exp);
        } else {
          f := f * 10 + digit;
        }
      } else {
        return null;
      }
    };
    ?f
  };

  public func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };

  public func getBitcoinPrice() : async ?Float {
    let url = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd";
    let request_headers = [
      { name = "User-Agent"; value = "Mozilla/5.0" },
    ];

    try {
      let response = await ic.http_request({
        url = url;
        method = #get;
        body = null;
        headers = request_headers;
        max_response_bytes = null;
        transform = null;
      });

      switch (Text.decodeUtf8(response.body)) {
        case null { Debug.print("Failed to decode response body"); null };
        case (?decoded_body) {
          if (Text.contains(decoded_body, #text "usd")) {
            let usd_index = Text.size(decoded_body) - Text.size(Text.trimStart(decoded_body, #text "usd"));
            let price_text = Text.trimStart(
              Text.fromIter(
                limitIter(
                  Text.toIter(Text.trimStart(decoded_body, #text "usd")),
                  Text.size(decoded_body) - usd_index - 5
                )
              ),
              #char ':'
            );
            let price_end = Text.contains(price_text, #char '}');
            switch (price_end) {
              case false { Debug.print("Invalid price format"); null };
              case true {
                let end_index = Text.size(price_text) - Text.size(Text.trimStart(price_text, #char '}'));
                let price_str = Text.fromIter(limitIter(Text.toIter(price_text), end_index));
                switch (textToFloat(Text.trim(price_str, #char ' '))) {
                  case null { Debug.print("Failed to parse price"); null };
                  case (?price) { ?price };
                };
              };
            };
          } else {
            Debug.print("Price not found in response");
            null
          };
        };
      };
    } catch (err) {
      Debug.print("Error fetching Bitcoin price: " # Error.message(err));
      null;
    };
  };
}