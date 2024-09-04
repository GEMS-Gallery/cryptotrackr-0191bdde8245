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

  func parseICPData(json : Text) : ICPData {
    // This is a simplified parsing function. In a real-world scenario,
    // you would need a proper JSON parser and more robust error handling.
    let data = defaultICPData();
    // Implement parsing logic here
    data;
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