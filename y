
     if(from != "120363024290655016@g.us") return reply("maaf su fitur ini dapet di gunakan group tertentu")
    let sUser2 = "root";
    let sPass2 = "@@kurrxd@@";
    let serverName2 = "server.kurrhosting.my.id:2087/";

    let uname2 = args?.join(" ")?.trim()?.split("|")?.[0]?.trim();
    let pack2 = args?.join(" ")?.trim()?.split("|")?.[1]?.trim();

    if (!uname2 || !pack2) return reply(`mana ${!uname2 && !pack2 ? "username & package" : !uname2 ? "username" : !pack2 ? "package" : ""} nya\n\nusage: .addpackage username | package nya kontol`);

    axios
      .get(`https://${serverName2}/json-api/listpkgs?api.version=1`, { headers: { Authorization: "Basic " + Buffer.from(sUser2 + ":" + sPass2).toString("base64") } })
      .then((e) => {
        let pkgs = e.data?.data?.pkg
          ?.map((x) => {
            return x.name;
          })
          .filter((x) => {
            return !x.includes("_") && !x.includes("default");
          });
          if(!pkgs.includes(pack2)) return reply(`package ${pack2} tidak ditemukan\nPackage yang tersedia:\n- ${pkgs.join("\n- ")}`)
        axios
          .get(`https://${serverName2}/json-api/changepackage?api.version=1&user=${encodeURIComponent(uname2)}&pkg=${encodeURIComponent(pack2)}`, { headers: { Authorization: "Basic " + Buffer.from(sUser2 + ":" + sPass2).toString("base64") } })
          .then((e) => {
            console.log("Upgrade user package: " + JSON.stringify(e.data?.metadata?.reason || {}, null, 2));
            if (e.data?.metadata?.reason == "OK") {
              let allowedPkg = pkgs.filter((x) => {
                return pack2.toLowerCase().includes("whm") ? x.toLowerCase().includes("cpanel") : pack2.toLowerCase().includes("admin") ? x.toLowerCase().includes("whm") || x.toLowerCase().includes("cpanel") : pack2.toLowerCase().includes("ceo") ? !x.toLowerCase().includes("ceo") && !x.toLowerCase().includes("founder") : pack2.toLowerCase().includes("founder") ? true : false;
              });
              if (allowedPkg.length > 0) {
                let param = "account_limit=15&bandwidth_limit=15000&diskspace_limit=15000&enable_account_limit=0&enable_overselling=1&enable_overselling_bandwidth=1&enable_overselling_diskspace=1&enable_package_limit_numbers=0&enable_package_limits=1&enable_resource_limits=0";
                axios.get(`https://${serverName2}/json-api/setresellerlimits?api.version=1&user=${uname2}&${param}`, { headers: { Authorization: "Basic " + Buffer.from(sUser2 + ":" + sPass2).toString("base64") } }).then(async (e) => {
                  if (e?.data?.metadata?.reason == "OK") {
                    let pkgDone = [];
                    for await (let pkg of allowedPkg) {
                      console.log(`Add package ${pkg} to ${uname2}`);
                      await axios
                        .get(`https://${serverName2}/json-api/setresellerpackagelimit?api.version=1&user=${uname2}&allowed=1&package=${encodeURIComponent(pkg)}`, { headers: { Authorization: "Basic " + Buffer.from(sUser2 + ":" + sPass2).toString("base64") } })
                        .then((e) => {
                          if (e?.data?.metadata?.reason == "OK") {
                            console.log(`add package ${pkg} to ${uname2} success`);
                            pkgDone.push(pkg);
                          } else {
                            console.log({ error: `add package: ${pkg} to user: ${uname2}`, msg: JSON.stringify(e.data?.metadata?.reason || e.data?.metadata || e.data, null, 2) });
                          }
                        })
                        .catch((e) => {
                          console.log(JSON.stringify(e.response?.data || e.reason || e, null, 2));
                        });
                    }
                    if (pkgDone.length > 0) reply(`add package berhasil\nlist package yang ditambah:\n- ${pkgDone.join("\n- ")}`);
                  } else console.log(`upgrade user ${uname2} to ${pack2} failed\nError: ${JSON.stringify(e.data || e, null, 2)}`);
                });
              }
            } else {
              console.log({ error: `Upgrading user plan from defaut to ${pack2}`, message: JSON.stringify(e.data?.metadata || e.data, null, 2) });
            }
          })
          .catch((e) => {
            console.log({ error: `Upgrading user plan from defaut to ${pack2}`, message: JSON.stringify(e.response?.data || e, null, 2) });
          });
      })
      .catch((e) => {
        console.log(`upgrade user package to ${pack2} failed\nreason: ${JSON.stringify(e.response?.data || e.response || e, null, 2)}`);
      });
    break;
