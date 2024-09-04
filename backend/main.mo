import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Int "mo:base/Int";
import Float "mo:base/Float";
import Char "mo:base/Char";
import IC "mo:ic";
import Iter "mo:base/Iter";
import Array "mo:base/Array";

actor {
  let ic : IC.Service = actor("aaaaa-aa");
  let COINGECKO_API_URL = "https://api.coingecko.com/api/v3";
  let ICP_ID = "internet-computer";

  public type ICPData = {
    price : Float;
    marketCap : Float;
    volume24h : Float;
    priceChange24h : Float;
    circulatingSupply : Float;
    totalSupply : Float;
    ath : Float;
    athDate : Text;
  };

  public func getICPData() : async ICPData {
    let url = COINGECKO_API_URL # "/coins/" # ICP_ID # "?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=false";
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
        case null { Debug.print("Failed to decode response body"); defaultICPData() };
        case (?decoded_body) {
          parseICPData(decoded_body);
        };
      };
    } catch (err) {
      Debug.print("Error fetching ICP data: " # Error.message(err));
      defaultICPData();
    };
  };

  func substring(t : Text, start : Nat, end : Nat) : Text {
    let chars = Iter.toArray(Text.toIter(t));
    let size = chars.size();
    let safeStart = if (start > size) size else start;
    let safeEnd = if (end > size) size else end;
    Text.fromIter(Iter.fromArray(Array.subArray(chars, safeStart, safeEnd - safeStart)));
  };

  func findSubstringIndex(text : Text, pattern : Text) : ?Nat {
    let textIter = Text.toIter(text);
    let patternIter = Text.toIter(pattern);
    var index = 0;
    label l loop {
      let char = textIter.next();
      switch (char) {
        case null { break l };
        case (?c) {
          switch (patternIter.next()) {
            case null { return ?index };
            case (?pc) {
              if (c == pc) {
                let matchIndex = index;
                var allMatch = true;
                var currentPatternIter = patternIter;
                label inner loop {
                  let nextPatternChar = currentPatternIter.next();
                  switch (nextPatternChar) {
                    case null { return ?matchIndex };
                    case (?pc) {
                      let nextTextChar = textIter.next();
                      switch (nextTextChar) {
                        case null { allMatch := false; break inner };
                        case (?tc) {
                          if (tc != pc) {
                            allMatch := false;
                            break inner;
                          };
                        };
                      };
                    };
                  };
                };
                if (allMatch) { return ?matchIndex };
                index := matchIndex;
                currentPatternIter := Text.toIter(pattern);
              };
            };
          };
        };
      };
      index += 1;
    };
    null;
  };

  func textToFloat(t : Text) : Float {
    var intPart : Int = 0;
    var fracPart : Float = 0;
    var fracDiv : Float = 10;
    var seenDot = false;
    var isNegative = false;

    for (c in t.chars()) {
      if (c == '-') {
        isNegative := true;
      } else if (c == '.') {
        seenDot := true;
      } else {
        let digit = Char.toNat32(c) - 48;
        if (digit >= 0 and digit <= 9) {
          if (seenDot) {
            fracPart += Float.fromInt(Int.fromNat(Nat32.toNat(digit))) / fracDiv;
            fracDiv *= 10;
          } else {
            intPart := intPart * 10 + Int.fromNat(Nat32.toNat(digit));
          };
        };
      };
    };

    let result = Float.fromInt(intPart) + fracPart;
    if (isNegative) -result else result;
  };

  func parseICPData(json : Text) : ICPData {
    var price : Float = 0;
    var marketCap : Float = 0;
    var volume24h : Float = 0;
    var priceChange24h : Float = 0;
    var circulatingSupply : Float = 0;
    var totalSupply : Float = 0;
    var ath : Float = 0;
    var athDate : Text = "";

    func extractFloat(key : Text) : Float {
      let keyIndex = findSubstringIndex(json, key);
      switch (keyIndex) {
        case null { 0 };
        case (?index) {
          let valueStart = index + key.size() + 2; // +2 for ":" and space
          let valueEnd = findSubstringIndex(substring(json, valueStart, json.size()), ",");
          switch (valueEnd) {
            case null { 0 };
            case (?end) {
              let valueText = substring(json, valueStart, valueStart + end);
              textToFloat(valueText);
            };
          };
        };
      };
    };

    price := extractFloat("\"current_price\":");
    marketCap := extractFloat("\"market_cap\":");
    volume24h := extractFloat("\"total_volume\":");
    priceChange24h := extractFloat("\"price_change_percentage_24h\":");
    circulatingSupply := extractFloat("\"circulating_supply\":");
    totalSupply := extractFloat("\"total_supply\":");
    ath := extractFloat("\"ath\":");

    // Extract athDate (simplified, assumes format "YYYY-MM-DD")
    let athDateKey = "\"ath_date\":";
    let athDateIndex = findSubstringIndex(json, athDateKey);
    switch (athDateIndex) {
      case null { };
      case (?index) {
        let dateStart = index + athDateKey.size() + 1; // +1 for opening quote
        let dateEnd = findSubstringIndex(substring(json, dateStart, json.size()), "\"");
        switch (dateEnd) {
          case null { };
          case (?end) {
            athDate := substring(json, dateStart, dateStart + end);
          };
        };
      };
    };

    {
      price = price;
      marketCap = marketCap;
      volume24h = volume24h;
      priceChange24h = priceChange24h;
      circulatingSupply = circulatingSupply;
      totalSupply = totalSupply;
      ath = ath;
      athDate = athDate;
    };
  };

  func defaultICPData() : ICPData {
    {
      price = 0.0;
      marketCap = 0.0;
      volume24h = 0.0;
      priceChange24h = 0.0;
      circulatingSupply = 0.0;
      totalSupply = 0.0;
      ath = 0.0;
      athDate = "";
    };
  };

  public func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };
}