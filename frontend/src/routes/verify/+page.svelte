<script lang="ts">
    import Button from "$lib/components/ui/button/button.svelte";
    import * as Card from "$lib/components/ui/card";
    import * as Alert from "$lib/components/ui/alert";
    import * as Table from "$lib/components/ui/table";
    import Label from "$lib/components/ui/label/label.svelte";
    import { Input } from "$lib/components/ui/input";

    import { onMount } from "svelte";

    import { defaultEvmStores as evm, connected } from "ethers-svelte";
    import { ethers } from "ethers";

    import RowCentered from "$lib/RowCentered.svelte";
    import ColCentered from "$lib/ColCentered.svelte";
    import BottleImage from "$lib/assets/Wine BottleSmall.png";
    import Checkmark from "$lib/assets/Checkmark.png";
    import Xmark from "$lib/assets/X-Mark.png";

    import {
        contractAdress,
        BottleStoreABI,
        headerArray,
    } from "$lib/constants";

    import { writable, type Writable } from "svelte/store";

    class Bottle {
        bottleId: number;
        typeOfGrape: string;
        sunnyHours: number[];
        rainMilimeters: number[];
        timeOfHarvest: string[];
        timeOfBottling: string[];
        constructor(
            bottleId: number,
            typeOfGrape: string,
            sunnyHours: number[],
            rainMilimeters: number[],
            timeOfHarvest: string[],
            timeOfBottling: string[],
        ) {
            this.bottleId = bottleId;
            this.typeOfGrape = typeOfGrape;
            this.sunnyHours = sunnyHours;
            this.rainMilimeters = rainMilimeters;
            this.timeOfHarvest = timeOfHarvest;
            this.timeOfBottling = timeOfBottling;
        }
    }

    let ID: string;
    const bottles: Writable<Bottle[]> = writable([]);
    let noSuchID: boolean = false;
    let noBottles: boolean = false;


    let provider: ethers.JsonRpcProvider | ethers.BrowserProvider;
    let signer: ethers.JsonRpcSigner
    let BottleStore: ethers.Contract


    let isThereWallet: boolean =false
    let tamperStatus: boolean = true
    let noServer=false
    let isMobile: boolean = false;

    async function listByID() {
        noSuchID=false;
        let intID:number = parseInt(ID,16)
        try {
            let temp = await BottleStore.returnBottleByID(intID);
            if (temp.typeOfGrape==''){
                noSuchID=true;
                return
            }
            let bottle = new Bottle(
                temp.bottleId,
                temp.typeOfGrape,
                temp.sunnyHours,
                temp.rainMilimeters,
                temp.timeOfHarvest,
                temp.timeOfBottling,
            );
            console.log(bottle)

            bottles.update((currentBottles) => {
                if (currentBottles.some((b) => b.bottleId === bottle.bottleId)) {
                    return currentBottles;
                } else {
                    return [...currentBottles, bottle];
                }

            });
            noSuchID=false;
            noBottles=false
        } catch (error:any) {
            if (error.reason=="Panic due to ARRAY_RANGE_ERROR(50)"){
                noSuchID=true;
            }


        }
    }

    async function listByOwner(){
        try{
        
            let temp=await BottleStore.ownersBottles();
        
            console.log(temp.length)
            if (temp.length==0){
                noBottles=true;
            }
            else{
                noBottles=false;
            }
            let bottleArray: Bottle[] = [];
            temp.forEach((bottle:Bottle) => {
                console.log(bottle)
                let tempBottle = new Bottle(
                    bottle.bottleId,
                    bottle.typeOfGrape,
                    bottle.sunnyHours,
                    bottle.rainMilimeters,
                    bottle.timeOfHarvest,
                    bottle.timeOfBottling,
                );
                bottleArray.push(tempBottle);
            });
            bottles.set(bottleArray);
        
        }catch(error:any){
            console.log(error)
        }   

    }

    async function listFromNFC(uid:string ){
        let tempID=parseInt(uid,16)
        let temp = await BottleStore.returnBottleByID(tempID);
        let bottle = new Bottle(
            temp.bottleId,
            temp.typeOfGrape,
            temp.sunnyHours,
            temp.rainMilimeters,
            temp.timeOfHarvest,
            temp.timeOfBottling,
        );
        

        bottles.update((currentBottles) => {
            if (currentBottles.some((b) => b.bottleId === bottle.bottleId)) {
                return currentBottles;
            } else {
                return [...currentBottles, bottle];
            }

        });

    }


    async function connectMetamaskContract() {
        await evm.setProvider();
        provider = new ethers.BrowserProvider((window as any).ethereum);
        signer = await provider.getSigner();
        BottleStore = new ethers.Contract(
            contractAdress,
            BottleStoreABI,
            signer,
        );
        
    }


    async function connectDirectContract(){
        const provider = new ethers.JsonRpcProvider("http://172.19.8.77:8545/");
        BottleStore = new ethers.Contract(
            contractAdress,
            BottleStoreABI,
            provider,
        );
        console.log("Direct connection")

    }

    async function connect(){
        if (typeof (window as any).ethereum !== "undefined"){
            isThereWallet = true
            await connectMetamaskContract();
        }
        else{
            await connectDirectContract()
        }
       
    }


    let s: string | null = null;
    let e: string | null = null;
    let c: string | null = null;
    let response: any = null;
    let error: string | null = null;

    onMount(async () => {
        isMobile = window.innerWidth < 768; // Adjust breakpoint if needed
        window.addEventListener("resize", () => {
        isMobile = window.innerWidth < 768;
        });
        
        
        await connect();
        const urlParams = new URLSearchParams(window.location.search);
        s = urlParams.get("s");
        e = urlParams.get("e");
        c = urlParams.get("c");
       
        if (!s || !e || !c) {
            console.log("Hiányzó NFC paraméterek!");
            return;
        }

        try {
            const backendURL = `http://172.19.8.77:5000/verify?s=${s}&e=${e}&c=${c}`;
            const res = await fetch(backendURL);
            response = await res.json();
            console.log(response)
            
            listFromNFC(response.uid)
            console.log(response.tamperstatus)
            if (response.tamperstatus!="Not tampered!"){
                tamperStatus=true
                
            }
            else{
                tamperStatus=false
            }

            
        } catch (err) {
            console.error("Hiba a backend elérésénél:", err);
            error = "Nem sikerült kapcsolatot létesíteni a szerverrel.";
            noServer=true;
        }

    });
</script>

{#if !connected && isThereWallet}
    <ColCentered>
        <Alert.Root class="bg-slate-900 w-3/4 p-10">
            <Alert.Title class="text-5xl text-slate-100"
                >Kérlek csatlakoztasd az ethereum pénztárcád!</Alert.Title
            >
            <Alert.Description class="text-2xl text-slate-400">
                Csatlakozás nélkül nem tudsz interaktálni a blokklánccal.
            </Alert.Description>
        </Alert.Root>
        <Button
            class="text-4xl text-slate-950 m-5 p-10"
            on:click={connect}>Connect</Button
        >
    </ColCentered>
{:else}
    <RowCentered>
        <div class="sm: hidden md:hidden lg:flex justify-center items-center  ">
            <img
                class="w-4/6 h-4/6 object-contain"
                src={BottleImage}
                alt="Wine Bottle"
            />
        </div>

        <Card.Root
            class="bg-slate-900 w-full sm:w-3/4 md:w-3/4 lg:w-1/2 h-fit"
        >
            <Card.Header>
                <Card.Title class="text-4xl mb-2"
                    >Ellenőrizd egy üveg eredetiségét!</Card.Title
                >

                <Card.Description class="text-base">
                   <!--  Le tudod ellenőrizni az üveged eredetiségét, az üveg
                    azonosítójának segítségével, mely után minden rögzített
                    adatot megtekinthetsz az üvegről. -->
                </Card.Description>
            </Card.Header>

            <Card.Content class="h-4/6">
                <form>
                    <Label>Üveg lekérés azonosító alapján</Label>
                    <Input type="string" bind:value={ID} />
                    <Button on:click={listByID} class="mt-2 w-full font-medium text-lg ">Üveg lekérése megadott azonosítóval</Button>
                    {#if isThereWallet}
                    <Button on:click={listByOwner} class="mt-2 w-full font-medium text-lg">Saját címmel regisztrált üvegek lekérése</Button>
                    {/if}
                </form>
                {#if noSuchID}
                    <Alert.Root class="text-center mt-1 mb-1"> 
                        <Alert.Title class="text-2xl text-slate-400">Nincs ilyen azonosítóval rendelkező üveg!</Alert.Title>
                    </Alert.Root> 
                {:else if noBottles}
                    <Alert.Root class="text-center mt-1 mb-1"> 
                        <Alert.Title class="text-2xl text-slate-400">Nincs regisztrált üveged!</Alert.Title>
                    </Alert.Root> 
                {:else if noServer}
                <Alert.Root class="text-center mt-1 mb-1"> 
                    <Alert.Title class="text-2xl text-slate-400">Nem elérhető a szerver!</Alert.Title>
                </Alert.Root> 
                {/if}
                
                <div class="max-h-96 overflow-y-scroll overflow-x-auto hidden lg:block">
                    <Table.Root class="w-fit">
                      <Table.Header>
                        <Table.Row class="w-min">
                          {#each headerArray as header}
                            <Table.Head class="text-center">{header}</Table.Head>
                          {/each}
                        </Table.Row>
                      </Table.Header>
                      <Table.Body class="w-fit">
                        {#each $bottles as bottle}
                          <Table.Row class="text-center sm:text-sm md:text-base lg:text-lg">
                            <Table.Cell>{bottle.bottleId.toString(16)}</Table.Cell>
                            <Table.Cell>{bottle.typeOfGrape}</Table.Cell>
                            <Table.Cell>{bottle.sunnyHours}</Table.Cell>
                            <Table.Cell>{bottle.rainMilimeters}</Table.Cell>
                            <Table.Cell>{bottle.timeOfHarvest}</Table.Cell>
                            <Table.Cell>{bottle.timeOfBottling}</Table.Cell>
                            <Table.Cell class="flex justify-center items-center">
                              <img
                                class="w-2/6 h-2/6 object-contain"
                                src={tamperStatus ? Xmark : Checkmark}
                                alt="Status"
                              />
                            </Table.Cell>
                          </Table.Row>
                        {/each}
                      </Table.Body>
                    </Table.Root>
                </div>

                <div class="block lg:hidden space-y-4">
                    {#each $bottles as bottle}
                      <Table.Root class="w-fit">
                        <Table.Body>
                          <Table.Row>
                            <Table.Head>ID:</Table.Head>
                            <Table.Cell>{bottle.bottleId.toString(16)}</Table.Cell>
                          </Table.Row>
                          <Table.Row>
                            <Table.Head>Grape Type:</Table.Head>
                            <Table.Cell>{bottle.typeOfGrape}</Table.Cell>
                          </Table.Row>
                          <Table.Row>
                            <Table.Head>Sunny Hours:</Table.Head>
                            <Table.Cell>{bottle.sunnyHours}</Table.Cell>
                          </Table.Row>
                          <Table.Row>
                            <Table.Head>Rainfall (mm):</Table.Head>
                            <Table.Cell>{bottle.rainMilimeters}</Table.Cell>
                          </Table.Row>
                          <Table.Row>
                            <Table.Head>Harvest Time:</Table.Head>
                            <Table.Cell>{bottle.timeOfHarvest}</Table.Cell>
                          </Table.Row>
                          <Table.Row>
                            <Table.Head>Bottling Time:</Table.Head>
                            <Table.Cell>{bottle.timeOfBottling}</Table.Cell>
                          </Table.Row>
                          <Table.Row>
                            <Table.Head>Status:</Table.Head>
                            <Table.Cell class="flex justify-center items-center">
                              <img class="w-6 h-6" src={tamperStatus ? Xmark : Checkmark} alt="Status" />
                            </Table.Cell>
                          </Table.Row>
                        </Table.Body>
                      </Table.Root>
                    {/each}
                </div>
            </Card.Content>

            <Card.Footer class="block">
                <div class="text-xl text-center text-slate-400">
                    Nem ellenőrizni szeretnél üveget?
                   
                </div>
               
                <div class="flex justify-evenly">
                    <Button class="text-sm sm:text-base md:text-lg lg:text-xl mt-1" variant="link" href="/register">Regisztráció</Button
                    >
                    <Button class="text-sm sm:text-base md:text-lg lg:text-xl mt-1" variant="link" href="/update"
                        >Frissítés</Button
                    >   
                    <Button class="text-sm sm:text-base md:text-lg lg:text-xl mt-1" variant="link" href="/transfer"
                        >Tulajdonjog</Button>    

                </div>
            </Card.Footer>
        </Card.Root>

        <div class="sm: hidden md:hidden lg:flex justify-center items-center  ">
            <img
                class="w-4/6 h-4/6 object-contain"
                src={BottleImage}
                alt="Wine Bottle"
            />
        </div>
    </RowCentered>
{/if}
