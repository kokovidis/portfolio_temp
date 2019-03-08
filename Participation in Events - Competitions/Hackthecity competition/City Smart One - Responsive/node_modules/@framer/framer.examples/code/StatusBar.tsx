import * as React from "react"
import { Frame, PropertyControls, ControlType } from "framer"

type Appearance = "dark" | "light"

interface Props {
    carrier: string
    appearance: Appearance
    batteryLevel: number
    width: number
    height: number
}

interface State {
    time: string
}

export class StatusBar extends React.Component<Partial<Props>, State> {
    static defaultProps = {
        carrier: "Framer",
        appearance: "dark",
        batteryLevel: 100,
        width: 200,
        height: 20,
    }

    static propertyControls: PropertyControls<Props> = {
        carrier: { type: ControlType.String, title: "Carrier" },
        appearance: {
            type: ControlType.Enum,
            options: ["dark", "light"],
            optionTitles: ["Dark", "Light"],
            title: "Appearance",
        },
        batteryLevel: {
            type: ControlType.Number,
            min: 0,
            max: 100,
            title: "Battery",
        },
    }

    timer: number

    state = {
        time: "9:00",
    }

    componentDidMount() {
        this.timer = window.setInterval(() => {
            this.updateTime()
        }, 1000)
    }

    componentWillUnmount() {
        window.clearInterval(this.timer)
    }

    updateTime = () => {
        const date = new Date()
        const time = ("0" + date.getHours()).slice(-2) + ":" + ("0" + date.getMinutes()).slice(-2)
        this.setState({ time })
    }

    render() {
        const { carrier, batteryLevel, appearance, width, height } = this.props

        return (
            <Frame
                width={width}
                height={height}
                background={null}
                style={{
                    fontSize: 12,
                    textAlign: "center",
                    color: appearance === "dark" ? "black" : "white",
                }}
            >
                <Frame top={0} left={0} right={0} height={20} background={null}>
                    <Frame width={100} left={0} top={0} height={20} background={null}>
                        <div
                            style={{
                                fill: "black",
                                stroke: "black",
                                width: "auto",
                                float: "left",
                                padding: 3,
                                marginLeft: 2,
                                paddingTop: 3,
                            }}
                            dangerouslySetInnerHTML={{ __html: signal(appearance) }}
                        />
                        <div style={{ float: "left", lineHeight: "20px" }}>{carrier}</div>
                    </Frame>
                    <Frame height={20} top={0} background={null}>
                        <div
                            style={{
                                fontFamily: "system-ui, -apple-system",
                                marginTop: "3px",
                            }}
                        >
                            {this.state.time}
                        </div>
                    </Frame>
                    <Frame width={100} right={0} top={0} height={20} background={null}>
                        <div
                            style={{
                                fill: "black",
                                stroke: "black",
                                width: "auto",
                                float: "right",
                                padding: 4,
                                paddingLeft: 5,
                                paddingTop: 4,
                            }}
                            dangerouslySetInnerHTML={{
                                __html: batterSVG(appearance, batteryLevel),
                            }}
                        />
                        <div style={{ float: "right", lineHeight: "20px" }}>{`${Math.round(batteryLevel)}%`}</div>
                    </Frame>
                </Frame>
            </Frame>
        )
    }
}

function batterSVG(appearance: Appearance, batteryLevel: number) {
    const color = appearance === "dark" ? "black" : "white"
    const batteryJuiceColor = batteryLevel <= 10 ? "red" : batteryLevel <= 20 ? "#FFCC01" : color

    return `<svg width="27px" height="12px" viewBox="0 0 27 12" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <g id="Symbols" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <g id="Bars/Status/Black" transform="translate(-343.000000, -4.000000)">
            <g id="Pin-Right" transform="translate(298.000000, 3.000000)">
                <g id="Battery" transform="translate(9.000000, 0.000000)">
                    <g transform="translate(36.000000, 1.500000)">
                        <path d="M3.2048565,0.5 C2.26431807,0.5 1.89540921,0.571239588 1.5147423,0.774822479 C1.19446913,0.946106445 0.946106445,1.19446913 0.774822479,1.5147423 C0.571239588,1.89540921 0.5,2.26431807 0.5,3.2048565 L0.5,8.2951435 C0.5,9.23568193 0.571239588,9.60459079 0.774822479,9.9852577 C0.946106445,10.3055309 1.19446913,10.5538936 1.5147423,10.7251775 C1.89540921,10.9287604 2.26431807,11 3.2048565,11 L22.0738202,11 C22.8614775,11 23.5,10.3614775 23.5,9.57382015 L23.5,3.2048565 C23.5,2.26431807 23.4287604,1.89540921 23.2251775,1.5147423 C23.0538936,1.19446913 22.8055309,0.946106445 22.4852577,0.774822479 C22.1045908,0.571239588 21.7356819,0.5 20.7951435,0.5 L3.2048565,0.5 Z" id="Border" stroke="${color}" opacity="0.4"></path>
                        <path d="M25,4 C25.8626136,4.2220214 26.5,5.00507154 26.5,5.93699126 C26.5,6.86891097 25.8626136,7.65196112 25,7.87398251 L25,4 Z" id="Nub" stroke="none" fill="${color}" opacity="0.4"></path>
                        <rect id="Charge" fill="${batteryJuiceColor}" x="2" y="2" width="${Math.round(
        (batteryLevel / 100) * 19 + 1
    )}" height="7.5" rx="0.5"></rect>
                    </g>
                </g>
            </g>
        </g>
    </g>
</svg>`
}

function signal(appearance: Appearance) {
    const color = appearance === "dark" ? "black" : "white"
    return `<svg width="17px" height="10px" viewBox="0 0 17 10" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <g id="Symbols" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <g id="Overrides/Status-Bar/Signal---Black" transform="translate(-6.000000, -5.000000)" fill="${color}">
            <g id="Group" transform="translate(6.000000, 3.000000)">
                <path d="M1,7.5 L2,7.5 C2.55228475,7.5 3,7.94771525 3,8.5 L3,11 C3,11.5522847 2.55228475,12 2,12 L1,12 C0.44771525,12 6.76353751e-17,11.5522847 0,11 L0,8.5 C-6.76353751e-17,7.94771525 0.44771525,7.5 1,7.5 Z M5.5,6 L6.5,6 C7.05228475,6 7.5,6.44771525 7.5,7 L7.5,11 C7.5,11.5522847 7.05228475,12 6.5,12 L5.5,12 C4.94771525,12 4.5,11.5522847 4.5,11 L4.5,7 C4.5,6.44771525 4.94771525,6 5.5,6 Z M10,4 L11,4 C11.5522847,4 12,4.44771525 12,5 L12,11 C12,11.5522847 11.5522847,12 11,12 L10,12 C9.44771525,12 9,11.5522847 9,11 L9,5 C9,4.44771525 9.44771525,4 10,4 Z M14.5,2 L15.5,2 C16.0522847,2 16.5,2.44771525 16.5,3 L16.5,11 C16.5,11.5522847 16.0522847,12 15.5,12 L14.5,12 C13.9477153,12 13.5,11.5522847 13.5,11 L13.5,3 C13.5,2.44771525 13.9477153,2 14.5,2 Z" id="Mobile-Signal"></path>
            </g>
        </g>
    </g>
</svg>`
}
